#!/usr/bin/env gem build
# encoding: utf-8

version_from_file = lambda do |name = 'VERSION', directory = File.dirname(__FILE__)|
  version_file = File.expand_path name, directory
  File.read(version_file).chomp
end

Gem::Specification.new 'jewel' do |gem|

  gem.version = version_from_file.call

  gem.summary = 'Gem metadata at your fingertips'
  gem.description = 'Provides an easy way to access information about a gem at runtime'
  gem.homepage = 'https://github.com/matheusmoreira/jewel'
  gem.license = 'Mozilla Public License, version 2.0'

  gem.author = 'Matheus Afonso Martins Moreira'
  gem.email = 'matheus.a.m.moreira@gmail.com'

  gem.files = `git ls-files`.split "\n"

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'redcarpet'
  gem.add_development_dependency 'rookie'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'yard'

end
