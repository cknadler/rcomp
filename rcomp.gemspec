# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "rcomp/version"

Gem::Specification.new do |s|
  s.name        = "rcomp"
  s.version     = RComp::VERSION
  s.authors     = ["Chris Knadler"]
  s.email       = ["takeshi91k@gmail.com"]
  s.homepage    = "https://github.com/cknadler/rcomp"
  s.summary     = "A simple framework for testing command line application output."
  s.description = "A simple framework for testing command line application output."

  s.rubyforge_project = "rcomp"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_runtime_dependency("thor", "~> 0.16.0")
  
  s.add_development_dependency("cucumber", "~> 1.2.1")
  s.add_development_dependency("aruba", "~> 0.5.0")
  s.add_development_dependency("rake", "~> 10.0.0")
end
