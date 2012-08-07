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

  # The name of the gem.
  #
  # @overload name
  #   Returns the name of the gem.
  #
  # @overload name(string)
  #   Sets the name of the gem.
  #
  #   @param [#to_s] string the gem's name
  #
  # @return [String] the gem's name
  def name!(*arguments)
    arguments.map! &:to_s
    metadata.send :name, *arguments
  end

  # The directory where the gem is located.
  #
  # @overload root
  #   Returns the gem's root directory.
  #
  # @overload root(directory)
  #   Sets the gem's root directory.
  #
  #   @param [#to_s] directory the path to the gem's root directory, relative to
  #     the location of the current file
  #
  # @return [String] the gem's root directory as an absolute path
  # @since 0.0.2
  def root(*arguments)
    unless arguments.empty?
      relative_to = arguments.shift.to_s
      # caller returns an array of strings that are like “file:line” or “file:line: in `method’”
      file = caller.first.sub /:\d+(:in .*)?\z/, ''
      directory = File.dirname file
      path = File.expand_path relative_to, directory
      arguments.clear.unshift Jewel::Path.new path
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

  # This gem's specification.
  #
  # @overload specification
  #   Returns this gem's specification.
  #
  # @overload specification(path_or_specification)
  #   Sets this gem's specification.
  #
  #   If given a +::Gem::Specification+ object, it will be used. If given a path
  #   to a file, it will be loaded.
  #
  #   If the given path is not absolute, it will be assumed to be relative to
  #   this gem's root directory.
  #
  #   @param [::Gem::Specification, #to_s] path_or_specification the existing
  #     gem specification or the path to it
  #
  # @return [::Gem::Specification] the gem specification
  # @see Jewel::Gem::Metadata#gem_specification
  def specification(*arguments)
    unless arguments.first.is_a? ::Gem::Specification
      path = Jewel::Path.new arguments.shift
      path = root.join path if path.relative?
      directory, gemspec = path.split
      Dir.chdir directory do
        spec = ::Gem::Specification.load gemspec.to_s
        arguments.clear.unshift spec
      end
    end if arguments.any?
    metadata.gem_specification *arguments
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

  specification 'jewel.gemspec'

end
