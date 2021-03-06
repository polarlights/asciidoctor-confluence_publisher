module Asciidoctor
  module ConfluencePublisher
    module Model
      class Attachment < Base
        attr_accessor :id, :title
        attr_reader :version

        def version=(ver)
          @version = Version.new(ver)
        end
      end
    end
  end
end

