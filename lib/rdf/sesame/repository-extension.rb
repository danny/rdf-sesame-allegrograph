require 'rdf/ntriples'

module RDF::Sesame
  class Repository 

  attr_accessor :repo, :type, :host, :proxy_host, :proxy_port, :ntripleWriter, :ntripleReader

  SphericalTypeString  = 'http://franz.com/ns/allegrograph/3.0/geospatial/spherical/degrees/-180.0/180.0/-90.0/90.0/1.0'

  #without this you get an error 
  #<Net::HTTPInternalServerError:0x00000100ef7828>
  #Non-structure argument nil passed to ref of structure slot 12
  def initializeSpatialRepository
      #initializeRepository2
      data = 'latmax=90&latmin=-90&longmax=180&longmin=-180&stripWidth=1&unit=degree'
      server.post(url('geo/types/spherical'), data, 'Content-Type' => 'application/x-www-form-urlencoded') do |response|
      case response
          when Net::HTTPSuccess
            @type = response.body
            response.body
          else
            raise RuntimeError, "Unable to initialze repository with spherical type"
        end
      end
  end

  #Not currently needed as it appears difficult to set the value of a blank node
  #The Allegro UI does it by passing in a json argument - so we'd need to swtich from ntriples to
  #JSON - this would require a lot of changes to the rdf-sesame code -- not reallyneeded, just use guid for blank node...
  def createBlankNode 
      raise NotImplemented
      #This code need sto be changed to use server.get (/blankNodes?amount=1)
      returnVal = ""
      Net::HTTP::Proxy(@proxy_host,@proxy_port).start(@host) { |http|
      req = Net::HTTP::Post.new('/repositories/test/blankNodes?amount=1')
      req.add_field('Authorization','Basic c3VwZXI6c3VwZXI=')

      http.request(req) do |response|
        puts "BASE: #{response.body}"
        response.body["_:"] = '' #remove the leading portion
        response.body["\n"] = ''
        returnVal = response.body
        puts "RETURN: #{returnVal}"
      end
      }
      returnVal
  end

  def createPolygon polygon
    createRawPolygon(uri_to_ntriple(polygon.subject), polygon.toTypedCoordURI.collect { |uri|  RDF::Writer.for(:ntriples).new.format_literal (uri) })
    insert(RDF::Statement.new(polygon.subject, RDF.type, polygon.type))
  end

  #returns json
  def sparql_query query
      query_url = RDF::URI.new(@uri)
      query_url.query_values = {'query' => query, 'queryLN' => 'sparql'}
      json = nil
      server.get(query_url, 'Accept' => 'application/json') do |response|
        case response
          when Net::HTTPSuccess
           json = sparql_result_helper response #TODO #HACK This fixes the return type for sparql ASK 
           if(json.nil?)
              json = ::JSON.parse(response.body)
           end
          else
            raise RuntimeError, "Error Sparql Query #{polyname}"
        end
      end
      json
  end

  #HACK - this code fixes the broken return type of allegrograph
  def sparql_result_helper response
    json = nil
    if (response.body == 'true' || response.body == 'false')
      json = JSON.parse ("{\"response\": \"#{response.body}\"}")
    end
    json
  end

  def loadPolygon polyname, type
      points = []  
     json = sparql_query "SELECT  ?o WHERE {#{uri_to_ntriple(polyname)} ?p ?o . }"
     
     if (json != nil)
     json['values'].each {|point|
      if (point[0] != uri_to_ntriple(type).to_s)
        points.push(RDF::Allegrograph::Point.fromString(point[0]))
      end
      }
      end
      points
  end

  def deletePolygon polygon
    server.delete(url(:statements, {:subj => uri_to_ntriple(polygon.subject)})) do |response|
      case response  
        when Net::HTTPSuccess
           # puts ntriple_to_uris(response.body)
           # response.body
        else
            raise RuntimeError, "Error Delete Poly"
      end
    end    
  end

  #Find all triples using the predicate that have a location in this polygon
  #predicate needs to be type RDF::URI
  def insidePoly polyname, predicate
      server.get(url(constructInsidePolyURL uri_to_ntriple(polyname), uri_to_ntriple(predicate)), 'Content-Type' => 'text/plain') do |response|
      case response
          when Net::HTTPSuccess
             ntriple_to_uris(response.body) 
          else
            raise RuntimeError, "Error insidePoly"
        end
      end

  end

  def ntriple_to_uris data
    stmts=[] 
    RDF::NTriples::Reader.new(data) do |reader|
        reader.each_statement do |statement|
          stmts.push(statement)
         end
   end
   stmts
  end

 def uri_to_ntriple  uri
     RDF::Writer.for(:ntriples).new.format_uri(uri)
  end


  def constructInsidePolyURL polyname, pred 
    "geo/polygon?polygon=#{escapeURI(polyname)}&predicate=#{escapeURI(pred)}&type=#{escapeURI(@type)}"
  end

   def escapeURI uri 
    URI.escape(uri, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
   end

  #Ruby Net::HTTP Error [#10340]  
  #http://rubyforge.org/tracker/?func=detail&atid=1698&aid=10340&group_id=426  
  def generate_form_data_body(params, sep = '&')
      params_array = params.map do |k,v| 
        v.inject([]){|c, val| c << "#{URI.escape(k.to_s)}=#{escapeURI(val.to_s)}"}.join(sep)
      end
      params_array.join(sep)
  end

  def createRawPolygon polyName, points
    data = generate_form_data_body({'point' => points, 'resource' => [polyName]})
      server.put(url('geo/polygon'), data, 'Content-Type' => 'application/x-www-form-urlencoded') do |response|
      case response
          when Net::HTTPSuccess
            response.body
          else
            raise RuntimeError, "Unable to create raw polygon"
        end
      end
  end

end
end
