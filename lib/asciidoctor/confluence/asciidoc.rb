module Asciidoctor
  module Confluence
    class Asciidoc
      attr_reader :path, :children

      def initialize(path)
        @path = path
        @children = []
      end

      def is_leaves?
        !is_directory?
      end

      def is_directory?
        File.directory?(path)
      end

      def add_child(child)
        return if child.nil?
        @children << child
      end

      def to_s
        inspect
      end

      def has_any_leaves?
        traverse_file_tree(self)
      end

      private
      def traverse_file_tree(root)
        return true if root.is_leaves?
        return root.children.any? { |node| traverse_file_tree(node) }
      end
    end
  end
end
