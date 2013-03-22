# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift File.expand_path('../lib', __FILE__)
name = "shadowbq-domainatrix"
require "domainatrix/version"

Gem::Specification.new name, Domainatrix::VERSION do |s|
  s.authors = ["Paul Dix", "Brian John", "Shadowbq", "Menno van der Sman", "Wouter Broekhof", "Wilson"]
  s.date    = %q{2013-03-21}
  s.license = 'MIT'
  s.email = ["shadowbq@gmail.com"]
  s.files = [
    "lib/domainatrix.rb",
    "lib/effective_tld_names.dat",
    "lib/domainatrix/domain_parser.rb",
    "lib/domainatrix/url.rb",
    "lib/domainatrix/version.rb",
    "CHANGELOG.md",
    "README.textile",
    "spec/spec.opts",
    "spec/spec_helper.rb",
    "spec/domainatrix_spec.rb",
    "spec/domainatrix/domain_parser_spec.rb",
    "spec/domainatrix/url_spec.rb"]
  s.homepage = %q{http://github.com/shadowbq/domainatrix}
  s.require_paths = ["lib"]
  s.required_rubygems_version = ">= 1.8.1"
  s.summary = %q{A cruel mistress that uses the public suffix domain list to dominate URLs by canonicalizing, finding the public suffix, and breaking them into their domain parts.}
  
  s.add_dependency("addressable")
  s.add_development_dependency("rspec")
  s.add_development_dependency("rake")
  s.add_development_dependency "bump", "~> 0.3"

end
