require "./spec_helper"

module Maze
  describe Tree do
    it "finds the root node" do
      tree = Tree(Symbol).new
      tree.add "/abcdef", :wrong
      tree.add "/", :right

      result = tree.lookup("/")
      result.should_not be_nil
      result.try(&.value).should eq(:right)
    end

    it "finds a simple adjacent node" do
      tree = Tree(Symbol).new
      tree.add "/def", :wrong
      tree.add "/abc", :right

      result = tree.lookup("/abc")
      result.should_not be_nil
      result.try(&.value).should eq(:right)
    end

    it "finds a simple nested node" do
      tree = Tree(Symbol).new
      tree.add "/abc", :wrong
      tree.add "/abcdef", :wrong
      tree.add "/abcdef2", :wrong
      tree.add "/abc/abc", :wrong
      tree.add "/abc/de", :wrong
      tree.add "/abcde/f2", :wrong
      tree.add "/abc/def", :right

      result = tree.lookup("/abc/def")
      result.should_not be_nil
      result.try(&.value).should eq(:right)
    end
  end
end
