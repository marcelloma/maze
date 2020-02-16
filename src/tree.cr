module Maze
  class Tree(T)
    def initialize
      @root = Node(T).new("/", nil)
    end

    def print
      print 0, @root
    end

    private def print(i, node)
      p "#{"- " * i}#{node.key} #{node.value?.to_s}"

      node.children.each do |child|
        print i + 1, child
      end
    end

    def add(path, value)
      add path, value, @root
    end

    private def add(key, value, node : Node(T))
      key_reader = Char::Reader.new(key)
      node_key_reader = Char::Reader.new(node.key)

      while key_reader.has_next? && node_key_reader.has_next?
        if key_reader.current_char != node_key_reader.current_char
          break
        end

        key_reader.next_char
        node_key_reader.next_char
      end

      new_key = key.byte_slice(key_reader.pos)

      if node_key_reader.has_next? && key_reader.has_next?
        new_node_key = node.key.byte_slice(node_key_reader.pos)
        new_node = Node.new(new_node_key, node.value?)
        new_node.children.replace(node.children)

        node.key = node.key.byte_slice(0, node_key_reader.pos)
        node.value = nil
        node.children = [new_node, Node.new(new_key, value)]

        return
      end

      if node_key_reader.has_next? && !key_reader.has_next?
        new_node_key = node.key.byte_slice(node_key_reader.pos)
        new_node = Node.new(new_node_key, node.value?)
        new_node.children.replace(node.children)

        node.key = key
        node.value = value
        node.children = [new_node]

        return
      end

      if !node_key_reader.has_next? && !key_reader.has_next?
        if node.value?
          raise Exception.new("duplicate node")
        else
          node.value = value
        end

        return
      end

      node.children.each do |child_node|
        if new_key[0]? == child_node.key[0]?
          add new_key, value, child_node

          return
        end
      end

      node.children << Node.new(new_key, value)
    end

    def lookup(path)
      result = Result(T).new
      lookup path, @root, result
    end

    private def lookup(key, node, result)
      key_reader = Char::Reader.new(key)
      node_key_reader = Char::Reader.new(node.key)

      while key_reader.has_next? && node_key_reader.has_next? &&
            (key_reader.current_char == node_key_reader.current_char ||
            node_key_reader.current_char == ':' ||
            node_key_reader.current_char == '?')
        if node_key_reader.current_char == ':' ||
           node_key_reader.current_char == '?'
          param_name_length = find_param_length(node_key_reader)
          param_name = node.key.byte_slice(node_key_reader.pos + 1, param_name_length - 1)

          param_value_length = find_param_length(key_reader)
          param_value = key.byte_slice(key_reader.pos, param_value_length)

          result.params[param_name] = param_value

          node_key_reader.pos += param_name_length
          key_reader.pos += param_value_length
        else
          key_reader.next_char
          node_key_reader.next_char
        end
      end

      if node_key_reader.has_next? && has_optional_param?(node_key_reader)
        result.value = node.value
        return result
      end

      if !node_key_reader.has_next? && !key_reader.has_next?
        result.value = node.value
        return result
      end

      new_key = key.byte_slice(key_reader.pos)

      node.children.each do |child_node|
        if new_key[0]? == child_node.key[0]? ||
           child_node.key[0]? == ':' ||
           child_node.key[0]? == '?'
          return lookup new_key, child_node, result
        end
      end
    end

    private def has_optional_param?(reader)
      has_optional_param = false

      original_pos = reader.pos

      while reader.has_next?
        break if reader.current_char == '/'

        reader.next_char
      end

      while reader.has_next?
        if reader.current_char == '?'
          has_optional_param = true
          break
        end

        reader.next_char
      end

      reader.pos = original_pos

      has_optional_param
    end

    private def find_param_length(reader)
      original_pos = reader.pos

      while reader.has_next?
        reader.next_char

        break if reader.current_char == '/'
      end

      length = reader.pos - original_pos

      reader.pos = original_pos

      length
    end
  end
end
