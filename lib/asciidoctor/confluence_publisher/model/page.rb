module Asciidoctor
  module ConfluencePublisher
    module Model
      class Page < Base
        attr_accessor :id, :title
        attr_reader :version, :ancestors, :space

        def version=(ver)
          @version = Version.new(ver)
        end

        def ancestors=(ancestors)
          @ancestors = ancestors.map { |ans| Ancestor.new(ans) }
        end

        def space=(space)
          @space = Space.new(space)
        end

        def contain_ancestor?(ancestor_id)
          @ancestors.any? { |ancestor| ancestor.id == ancestor_id.to_s }
        end
      end
    end
  end
end
