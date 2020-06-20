module Asciidoctor
  module ConfluencePublisher
    module Model
      class Property < Base
        attr_accessor :key, :value
        attr_reader :version

        def version=(ver)
          @version = Version.new(ver)
        end
      end
    end
  end
end
