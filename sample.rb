require 'rubygems'
#require 'rdf'
#require 'spira'
#require 'rdf/ntriples'
#require 'rdf/sesame'
#require 'json'
#require 'uuid'
require 'rdf-sesame-allegrograph'


url    = RDF::URI("http://sed3-rdf.mitre.org:10035")
server = RDF::Sesame::Server.new(url, {:user=> 'super', :pass => 'super', :proxy_host => 'localhost', :proxy_port => 8888})

repo = server.repositories['test']
repo.initializeSpatialRepository

Spira.add_repository! :default, repo

module RDF
  class HAK < Vocabulary("http://www.mitre.org/sed3/allegro/ontology#")

    #datatypes
    property :person
    property :datafeed
    property :device
    
    #relations
    property :locaiton
    property :hadevice
    property :area
    property :name
    
  end
end



class Device
  include Spira::Resource
  type RDF::HAK.device
  base_uri :default

  property :name, :predicate => FOAF.name, :type => String
end

class Person
  include Spira::Resource
  type RDF::HAK.person
  base_uri :default

  property :name, :predicate => FOAF.name, :type => String
  property :description, :predicate => FOAF.description, :type => String
  property :homepage, :predicate => FOAF.homepage, :type => String
  property :nickname, :predicate => FOAF.nick, :type => String
  property :location, :predicate => RDF::HAK.location, :type => RDF::Allegrograph::SphericalPoint
  property :device, :predicate => RDF::HAK.hadevice, :type => :Device
end

class DataFeed
  include Spira::Resource
  type RDF::HAK.datafeed
  base_uri :default

  property :name, :predicate => HAK.feedname, :type => String
  property :area, :predicate => HAK.area, :type => :'RDF::Allegrograph::Polygon'
end

df = DataFeed.for RDF::URI ("http://www.mitre.org/sed3/data/feeds#ied1")
df.name = "Super Awesome Data Feed #1!"

if df.area != nil
  puts "AREA LOADED: #{df.area.points.inspect}"
end
df.area = RDF::Allegrograph::Polygon.new({:_subject => RDF::Allegrograph::BNode.new}, [[0,0], [80,0],[80,80],[0,80]])
df.area.save!
df.save!

person = Person.for RDF::URI("http://www.mitre.org/sed3/data/people#Danny")
person.name = "Danny"
person.description = "Programer"
person.location = RDF::Allegrograph::Point.new 20, 20
dd = Device.for(RDF::Allegrograph::BNode.new)
dd.name = "My Device"
dd.save!
person.device = dd
person.save!

puts "\n\tInside:"
puts df.area.inside RDF::HAK.location

puts 'SPARQL SAMPLE'
#val = "Medic"
#type = "<http://sed3.mitre.org/types#role>"
#query="PREFIX foaf:<http://xmlns.com/foaf/0.1/>
#         PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
#         PREFIX sed3:<http://sed3.mitre.org/ontology#>
#         SELECT ?guidurl { ?guidurl sed3:name  \""+val  +"\" . ?guidurl rdf:type " +type  +" }"

query = "SELECT * {?s ?p ?o}"
result = repo.sparql_query query
puts result
puts result['values'][0][0]


#df.area.destroy!
puts 'Press Enter To Delete All Statements'
gets

#Call private method to empty the database
repo.send :clear_statements
puts 'Done, Repo Empty? ' +repo.empty?.to_s



