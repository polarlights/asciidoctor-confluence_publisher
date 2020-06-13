module Asciidoctor
  module Confluence
    class Invoker
      attr_reader :options
      def initialize(options)
        @options = options.dup
        @options[:to_file] = nil
        @options[:confluence_host] = options[:confluence_host] || ENV['CONFLUENCE_HOST']
        @options[:space] = options[:space] || ENV['SPACE']
        @options[:username] = options[:username] || ENV['CONFLUENCE_USERNAME']
        @options[:password] = options[:password] || ENV['CONFLUENCE_PASSWORD']
        @options[:ancestor_id] = options[:ancestor_id] || ENV['ANCESTOR_ID']
        @options[:page_id] = options[:page_id] || ENV['PAGE_ID']
        @options[:strategy] = options[:strategy] || ENV['STRATEGY']
        init_confluence_options
      end

      def invoke!
        Array(options[:input_files]).each do |input_file|
          document = Asciidoctor.load_file input_file, options
          puts "hello"
        end
      end

      private
      def init_confluence_options
      end
    end
  end
end