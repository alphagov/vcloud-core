# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'vcloud/core/version'

Gem::Specification.new do |s|
  s.name        = 'vcloud-core'
  s.version     = Vcloud::Core::VERSION
  s.authors     = ['GOV.UK Infrastructure']
  s.email       = ['vcloud-tools@digital.cabinet-office.gov.uk']
  s.summary     = 'Core tools for interacting with VMware vCloud Director'
  s.description = 'Core tools for interacting with VMware vCloud Director. Includes vCloud Query, a light wrapper round the vCloud Query API.'
  s.homepage    = 'http://github.com/gds-operations/vcloud-core'
  s.license     = 'MIT'

  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) {|f| File.basename(f)}
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.2.2'

  s.add_runtime_dependency 'fog', '~> 1.40.0'
  s.add_runtime_dependency 'mustache', '~> 0.99.0'
  s.add_runtime_dependency 'highline'
  s.add_runtime_dependency 'nokogiri', '~> 1.6.8.1'
  s.add_development_dependency 'gem_publisher', '1.2.0'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake', '>= 12'
  s.add_development_dependency 'rspec', '>= 3.6'
  s.add_development_dependency 'rubocop', '~> 0.49.1'
  s.add_development_dependency 'simplecov', '~> 0.14.1'
  s.add_development_dependency 'vcloud-tools-tester'
end
