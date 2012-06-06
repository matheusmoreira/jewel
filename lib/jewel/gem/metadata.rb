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

      # Uses the stored information to generate a ::Gem::Specification.
      #
      # @return [::Gem::Specification] the specification
      def to_spec
        ::Gem::Specification.new do |gem_specification|

          # Set all attributes
          stored_attributes.keys.each do |key|
            writer_method = '='.prepend(key.to_s).intern
            if gem_specification.respond_to? writer_method
              gem_specification.send writer_method, stored_attributes[key]
            end
          end

          # Add the dependencies
          {
            :add_runtime_dependency => dependencies,
            :add_development_dependency => development_dependencies
          }.each do |method_name, dependencies|
            dependencies.each do |gem_name, version|
              arguments = [gem_name, version].compact.map &:to_s
              gem_specification.send method_name.intern, *arguments
            end
          end
        end
      end

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
