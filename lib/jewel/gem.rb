require 'jewel/gem/metadata'

module Jewel

  # Stores information about a gem.
  #
  # @author Matheus Afonso Martins Moreira
  # @since 0.0.1
  class Gem
  end

end

class << Jewel::Gem

  # The gem metadata.
  #
  # @return [Jewel::Gem::Metadata] this gem's metadata
  def metadata
    @metadata ||= Jewel::Gem::Metadata.new
  end

  # Forwards everything to this gem's {metadata}.
  def method_missing(method_name, *arguments, &block)
    metadata.send method_name, *arguments, &block
  end

  # Sets the name of the gem. Returns the name if not given an argument.
  #
  # @param [String, Symbol, #to_s] name the name of the gem
  # @return [String] the name of the gem
  def name!(name = nil)
    arguments = [ name ].compact.map &:to_s
    metadata.send :name, *arguments
  end

  # Adds a runtime dependency.
  #
  # If called within a {development} context, a development dependency will be
  # added instead.
  #
  # @param [String, Symbol, #to_s] gem the name of the gem
  # @param [String, Symbol, #to_s] version the version of the gem
  # @see development
  # @example
  #   depend_on :jewel    # runtime dependency
  #
  #   development do
  #     depend_on :rspec  # development dependency
  #   end
  def depend_on(gem, version = nil)
    metadata.send(if development?
      :development_dependencies
    else :dependencies end).merge! gem => version
  end

  # Executes the given block within a development context, turning runtime
  # dependencies into development dependencies.
  #
  # @param [Proc] block the block to evaluate
  # @see depend_on
  # @example
  #   development do
  #     depend_on :rspec
  #   end
  def development(&block)
    @development = true
    instance_eval &block
  ensure
    @development = false
  end

  # Returns this gem's specification.
  #
  # @return [::Gem::Specification] the gem specification
  # @see Jewel::Gem::Metadata.to_spec
  def spec
    metadata.to_spec
  end

  alias gemspec spec
  alias to_spec spec

  private

  # Whether we are in a development context.
  #
  # @return [true, false] whether development mode is enabled
  # @see development
  def development?
    !!@development
  end

end

class Jewel::Gem

  name! :jewel
  summary 'Easy access to gem metadata'
  version '0.0.1'
  homepage 'https://github.com/matheusmoreira/jewel'
  license 'Mozilla Public License, version 2.0'

  author 'Matheus Afonso Martins Moreira'
  email 'matheus.a.m.moreira@gmail.com'

  files `git ls-files`.split "\n"

  development do
    depend_on :bundler
    depend_on :redcarpet  # yard uses it for markdown formatting
    depend_on :rookie
    depend_on :yard
  end

end
