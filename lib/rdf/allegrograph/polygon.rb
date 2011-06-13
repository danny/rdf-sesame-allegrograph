module RDF::Allegrograph
  
  class Polygon 
    #Review Section Below Where SPIRA Methods are overriden
    include Spira::Resource #need to include this, since classize_resource checks the inheritance chain
    type RDF::ALLEGRO.polygon
    default_source :profilemanager
    #base_uri :geo
                  #RDF::URI
    attr_accessor  :points
  
    #TODO validation? must have 3 points?

    def self.fromURI uri
      self.new({:_subject=>RDF::URI(uri)}, [])
    end

    #lat lon latlon array
    def self.fromLatLonArray name, pointArray
      self.new name, pointArray
      #fromPoints name, pointArray.collect { |pair| Point.new(pair[0], pair[1]) }
    end

    def self.fromPoints name, pointArray
      p = self.new name #call constructor and manually set points 
      p.subject = name
      p.points = pointArray
      p
    end

    def setPoints latlonArray
      @points = latlonArray.collect { |pair| Point.new(pair[0], pair[1]) }

    end

    def toTypedCoordURI 
      points.collect { |point| point.toTypedCoordURI }
    end

    def inside predicate
      self.class.repository_or_fail.insidePoly self, predicate 
    end

    def to_s
      points.to_s
    end
    
    ##############################
    #                            #
    # SPIRA OVERIDE FOR ALLEGRO  #
    #                            #
    ##############################

    #In Order to deal with broken RDF we need to overide save and load methods...

    #called from class_methods.project
    def initialize hash={:_subject => RDF::Allegrograph::BNode.new}, pointArray=[] 
     #handle th case where it loads :)
      @subject = hash[:_subject] 
      storedPoints  = self.class.repository_or_fail.loadPolygon @subject, self.type 
      if (storedPoints.length > 0 and pointArray.length > 0)
        raise RuntimeError, "Error trying to creat a polygon with name when one already exists"
      elsif (storedPoints.length > 0)
        @points = storedPoints
      else  
        setPoints pointArray
      end
    end

    #overide self.each from class_method

    #instance methods

    def _update!
      self.class.repository_or_fail.createPolygon self
    end

    def destroy!
      self.class.repository_or_fail.deletePolygon self
      super :object #delete all links to this node
      # super ({:subject => @subject})
    end

    #relaod_attributes
    #destroy attributes
    #copy_resource
    #rename
  end
end
