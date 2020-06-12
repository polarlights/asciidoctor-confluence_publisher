module Asciidoctor
  module Confluence
    module Model
      class Attachment < Base
        attr_accessor :id, :title, :version

        def version=(ver)
          Version.new(ver)
        end
      end
    end
  end
end

