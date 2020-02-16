module Maze
  class Result(T)
    @value : T?

    property value
    property? value
    property params

    def initialize
      @params = {} of String => String
    end
  end
end
