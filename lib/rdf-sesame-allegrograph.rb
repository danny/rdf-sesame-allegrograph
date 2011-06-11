require 'rdf'
#require 'rdf/sesame'
require 'rdf/ntriples'
require 'spira'
require 'json'
require 'uuid'

module  RDF::Sesame::Allegrograph
# Your code goes here...
  VERSION = "0.0.2"
  require 'rdf/sesame/repository-extension.rb'
  require 'rdf/vocab/allegro.rb' 
  require 'rdf/allegrograph/bnode.rb'
  require 'rdf/allegrograph/point.rb'
  require 'rdf/allegrograph/polygon.rb'
  require 'rdf/allegrograph/spherical_point.rb'
end
