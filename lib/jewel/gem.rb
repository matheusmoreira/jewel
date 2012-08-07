require 'jewel/gem/metadata'
require 'jewel/path'

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

  # Sets the root of the gem, relative to the directory where the current file
  # is located. Returns the gem root if not given an argument.
  #
  # @param [String, #to_s] relative_to the gem root relative to the current
  #                                    directory
  # @return [String] the gem root as an absolute path
  # @since 0.0.2
  def root(relative_to = nil)
    arguments = []
    unless relative_to.nil?
      relative_to = relative_to.to_s
      # caller returns an array of strings that are like “file:line” or “file:line: in `method’”
      file = caller.first.sub /:\d+(:in .*)?\z/, ''
      directory = File.dirname file
      path = File.expand_path(relative_to, directory)
      arguments.push Jewel::Path.new path
    end
    metadata.send :root, *arguments
  end

  # Adds a runtime dependency.
  #
  # If called within a {development} context, a development dependency will be
  # added instead.
  #
  # @param [String, Symbol, #to_s] gem the name of the gem
  # @param [Array<String>] requirements the version requirements
  # @see development
  # @example
  #   depend_on :jewel    # runtime dependency
  #
  #   development do
  #     depend_on :rspec  # development dependency
  #   end
  def depend_on(gem, *requirements)
    method = development? ? :add_development_dependency : :add_dependency
    specification.send method, gem.to_s, *requirements
  end

  alias depends_on depend_on

  # Makes sure the correct versions of this gem's dependencies are loaded at
  # runtime, no matter which versions are installed locally.
  #
  # @option options [true, false, :only] :development (false) which set of
  #   dependencies should be activated
  # @since 0.0.2
  def activate_dependencies!(options = {})
    metadata.each_dependency options do |name, *requirements|
      gem name, *requirements unless requirements.empty?
    end
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

  # Returns this gem's specification. If passed an existing instance, it will be
  # stored as this gem's specification.
  #
  # @param [::Gem::Specification] existing_specification the existing instance
  # @return [::Gem::Specification] the gem specification
  # @see Jewel::Gem::Metadata#gem_specification
  def specification(existing_specification = nil)
    metadata.gem_specification existing_specification
  end

  alias spec    specification
  alias to_spec specification

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

  root '../..'

  specification ::Gem::Specification.load root.join('jewel.gemspec').to_s

end
