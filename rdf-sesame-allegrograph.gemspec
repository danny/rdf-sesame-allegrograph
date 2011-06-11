# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
#require 'rdf/sesame'
require "rdf-sesame-allegrograph"

Gem::Specification.new do |s|
  s.name        = "rdf-sesame-allegrograph"
  s.version     = RDF::Sesame::Allegrograph::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Danny Gagne"]
  s.email       = ["danny+rdf-sesame-allegro@dannygagne.com"]
  s.homepage    = ""
  s.summary     = %q{Extension to the rdf-sesame gem to support features of allegrograph. }
  s.description = %q{Extends the rdf-sesame & spira gems.  Adds Support for the for sparql queries, geospatial queries, points, polygons, etc}

  s.rubyforge_project = "rdf-sesame-allegrograph"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
