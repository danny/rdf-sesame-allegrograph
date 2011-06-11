module RDF::Allegrograph
class BNode < RDF::URI
  def initialize 
    #TODO 
    #HACK 
    #Should call into allegro_repository and have the server generate the blank node
    #unfortunately we need to figure out how to call allegro so we can assign values to a bnode
    super "#{RDF::ALLEGRO.bnode}_#{UUID.new.generate}"
  end
end
end
