module Maze
  class Node(T)
    property key
    property value
    property? value
    property children

    def initialize(@key : String, @value : T?)
      @children = [] of Node(T)
    end
  end
end
