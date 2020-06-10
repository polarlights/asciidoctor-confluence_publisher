module Asciidoctor
  module Confluence
    class Invoker
      attr_reader :options
      def initialize(options)
        @options = options.dup
        @options[:to_file] = nil
      end

      def invoke!
        Array(options[:input_files]).each do |input_file|
          document = Asciidoctor.load_file input_file, options
          puts "hello"
        end
      end
    end
  end
end