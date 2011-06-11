module RDF::Allegrograph
  
  SphericalTypeString  = 'http://franz.com/ns/allegrograph/3.0/geospatial/spherical/degrees/-180.0/180.0/-90.0/90.0/1.0'

  class SphericalPoint
    include Spira::Type

    def self.unserialize (value)
      Point.fromURI "\"#{value.object}\""
    end

    def self.serialize (value)
      RDF::Literal.new(value.toCoordString, {:datatype => SphericalTypeString})
    end

    #allow data type be referened byr url
    #register_alias ALLEGRO.point
  end

end
