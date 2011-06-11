module RDF::Allegrograph
    class Point
        attr_accessor :lat, :lon

        def initialize lat, lon
            @lat = lat
            @lon = lon
        end

        def toCoordString
            latitude_to_iso(@lat) + longitude_to_iso(@lon)
        end

        def toTypedCoordURI 
          RDF::Literal.new(toCoordString, {:datatype => RDF::Sesame::Repository::SphericalTypeString})
        end
        
                  #RDF::URI
        def self.fromURI uri
            fromString (uri.to_s)
        end

      private

        def latitude_to_iso(value)
            float_to_iso value, 2
        end

        def longitude_to_iso(value)
            float_to_iso value, 3
        end

        def float_to_iso(value, digits)
            sign = "+"
            if value < 0
                sign = "-"
                value = -value
            end
            floor = value.to_i
            sign + (("%%0%dd" % digits) % floor) + (".%04d" % ((value - floor) * 100))
        end


        def self.fromString  coordinateString
            a =  parseCoord(coordinateString)
            p = Point.new a[0], a[1] 
        end

        def self.parseCoord(val) ; puts val
            #v  = val.scan(/\D\d*\D\d*/)
            v  = val.scan(/"(\D\d+)(\D\d.+)"/)[0]
            lat = v[0].to_i/10000
            lon = v[1].to_i/10000
            [lat, lon]
        end
    end
end
