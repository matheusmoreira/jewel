require 'pathname'

module Jewel
  class Gem

    # A Pathname which allows one to access subdirectories by chaining methods.
    #
    # @author Matheus Afonso Martins Moreira
    # @since 0.0.5
    class Root < Pathname

      # Joins the name of the missing method and all arguments with this
      # Pathname.
      #
      # @return [Jewel::Gem::Root] new instance with the results of the join
      def method_missing(method_name, *arguments, &block)
        arguments.unshift method_name.to_s
        pathname = join *arguments
        self.class.new pathname
      end

    end

  end
end
