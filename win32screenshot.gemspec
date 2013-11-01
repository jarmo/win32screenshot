# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "win32/screenshot/version"

Gem::Specification.new do |s|
  s.name = "win32screenshot"
  s.version = Win32::Screenshot::VERSION
  s.authors = ["Jarmo Pertman", "Aslak Hellesøy"]
  s.email = ["jarmo.p@gmail.com", "aslak.hellesoy@gmail.com"]
  s.description = "Capture Screenshots on Windows with Ruby to bmp, gif, jpg or png formats."
  s.homepage = "http://github.com/jarmo/win32screenshot"
  s.summary = "Capture Screenshots on Windows with Ruby to bmp, gif, jpg or png formats."
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]
  s.license = "MIT"
  
  s.add_dependency("ffi", "~> 1.0")
  s.add_dependency("mini_magick", "~> 3.5.0")
  s.add_dependency("rautomation", "~> 0.7")
  
  s.add_development_dependency("rspec", "~> 2.5")
  s.add_development_dependency("yard")
  s.add_development_dependency("rake")
end
