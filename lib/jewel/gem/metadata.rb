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
      # @since 0.0.1
      def initialize(&block)
        instance_eval &block unless block.nil?
      end

      # Associates the name of the missing method with the given arguments.
      #
      # @since 0.0.1
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
      # @since 0.0.1
      def dependencies
        @dependencies ||= {}
      end

      # This gem's development dependencies.
      #
      # @return [Hash] name => version pairs
      # @since 0.0.1
      def development_dependencies
        @development_dependencies ||= {}
      end

      # Use the stored information to generate a ::Gem::Specification.
      #
      # @return [::Gem::Specification] the specification
      # @since 0.0.1
      def to_spec
        ::Gem::Specification.new do |gem_specification|

          # Set all attributes
          stored_attributes.keys.each do |key|
            writer = '='.prepend key.to_s
            gem_specification.send writer, stored_attributes[key] if gem_specification.respond_to? writer
          end

          # Add the dependencies
          {
            :add_runtime_dependency => dependencies,
            :add_development_dependency => development_dependencies
          }.each do |method_name, dependencies|
            dependencies.each do |gem_name, version|
              gem_specification.send method_name.intern, gem_name.to_s, version
            end
          end
        end
      end

      private

      # The stored gem attributes.
      #
      # @return [Hash] hash holding information about the gem
      # @since 0.0.1
      def stored_attributes
        @stored_attributes ||= {}
      end

    end

  end
end
