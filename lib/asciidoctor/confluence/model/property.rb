module Asciidoctor
  module Confluence
    module Model
      class Property < Base
        attr_accessor :key, :value, :version

        def version=(ver)
          @version = Version.new(ver)
        end
      end
    end
  end
end
