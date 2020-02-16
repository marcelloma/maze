module Maze
  class Result(T)
    property value
    property? value
    property params

    @value : T?

    def initialize
      @params = {} of String => String
    end
  end
end
