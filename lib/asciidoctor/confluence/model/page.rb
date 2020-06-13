module Asciidoctor
  module Confluence
    module Model
      class Page < Base
        attr_accessor :id, :title, :space, :version, :ancestors

        def version=(ver)
          @version = Version.new(ver)
        end

        def ancestors=(ancestors)
          @ancestors = ancestors.map { |ans| Ancestor.new(ans) }
        end

        def space=(space)
          @space = Space.new(space)
        end
      end
    end
  end
end
