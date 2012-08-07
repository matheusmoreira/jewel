require 'pathname'

module Jewel

  # A Pathname that allows subdirectory access through method chaining.
  #
  # @author Matheus Afonso Martins Moreira
  # @since 0.1.0
  class Path < Pathname

    # Joins the name of the missing method and all arguments with this Pathname.
    #
    # @return [Jewel::Path] new instance with the results of the join
    def method_missing(*arguments, &block)
      arguments.map! &:to_s
      self.class.new join(*arguments), &block
    end

  end

end
