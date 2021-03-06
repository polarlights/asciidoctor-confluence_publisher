module Asciidoctor
  module ConfluencePublisher
    module Model
      class Base
        def initialize(hash = {})
          accessor_methods = public_methods(false).select { |mth| mth.to_s =~ /\w+=$/ }
          hash.each do |key, val|
            setter_method = "#{key}="
            if accessor_methods.include?(setter_method.to_sym)
              public_send(setter_method, val)
            end
          end
        end

        def to_s
          inspect
        end
      end
    end
  end
end
