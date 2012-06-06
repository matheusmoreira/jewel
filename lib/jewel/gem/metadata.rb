module Jewel
  class Gem

    # Stores Ruby gem metadata.
    #
    # @author Matheus Afonso Martins Moreira
    # @since 0.0.1
    class Metadata

      # Creates a new, empty set of gem metadata.
      #
      # If given a block, it will be evaluated in the context of the new
      # instance.
      #
      # @param [Proc] block the initializer block
      def initialize(&block)
        instance_eval &block unless block.nil?
      end

      # Associates the name of the missing method with the given arguments.
      def method_missing(method_name, *arguments, &block)
        method = method_name.to_s.gsub(/[=?!\z]/ix, '').strip.intern
        count = arguments.count
        return stored_attributes[method] if count.zero?
        value = count == 1 ? arguments.first : arguments
        stored_attributes[method] = value
      end

      # This gem's runtime dependencies.
      #
      # @return [Hash] name => version pairs
      def dependencies
        @dependencies ||= {}
      end

      # This gem's development dependencies.
      #
      # @return [Hash] name => version pairs
      def development_dependencies
        @development_dependencies ||= {}
      end

      # Runtime and development dependencies. The former takes precedence,
      # should version requirements conflict.
      #
      # @return [Hash] name => version pairs
      # @since 0.0.2
      def all_dependencies
        development_dependencies.merge dependencies
      end

      # Yields dependencies to the given block, or returns an enumerator.
      #
      # @option options [true, false, :only] :development (false) whether
      #   runtime and development dependencies should be included
      # @yieldparam [String] gem_name the name of the gem
      # @yieldparam [String, nil] version the required version
      # @since 0.0.2
      def each_dependency(options = {})
        return enum_for :each_dependency, options unless block_given?
        development = options.fetch :development, false
        case development
          when :only then development_dependencies
          when  true then all_dependencies
          else dependencies
        end.each do |gem_name, version|
          yield gem_name.to_s, version
        end
      end

      # The Gem::Specification.
      #
      # @return [::Gem::Specification] the specification
      # @since 0.0.4
      def gem_specification
        @gem_specification ||= Gem::Specification.new
      end

      alias spec    gem_specification
      alias gemspec gem_specification
      alias to_spec gem_specification

      private

      # The stored gem attributes.
      #
      # @return [Hash] hash holding information about the gem
      def stored_attributes
        @stored_attributes ||= {}
      end

    end

  end
end
