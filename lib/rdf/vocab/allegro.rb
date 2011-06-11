module RDF
  class ALLEGRO < Vocabulary("http://www.mitre.org/sed3/allegro/ontology#")

    #datatypes
    property :point
    property :polygon
    property :geometry
    property :bnode
    
    #relations
    property :haspoint
    property :haspolygon
    property :hasgeometry
    
  end
end
