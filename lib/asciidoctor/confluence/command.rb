require 'asciidoctor_confluence'
require 'asciidoctor/cli'

module Asciidoctor
  module Confluence
    class Command
      # default template directory for asciidoctor_confluence marcos
      DEFAULT_TEMPLATE_DIR = File.expand_path("../../../../template", __FILE__)

      def self.execute args
        options = Asciidoctor::Cli::Options.new

        unless ARGV != ['-v'] && (ARGV & ['-V', '--version']).empty?
          $stdout.write %(Asciidoctor Confluence #{Asciidoctor::Confluence::VERSION} using )
          options.print_version
          exit 0
        end

        case (result = options.parse! ARGV)
        when Integer
          exit result
        else
          options[:backend] = 'xhtml5'
          options[:template_dirs] = Array(options[:template_dirs]) << DEFAULT_TEMPLATE_DIR
          options[:to_file] = false
          options[:header_footer] = false
          invoker = Asciidoctor::Confluence::Invoker.new options
          GC.start
          invoker.invoke!
          exit invoker.code
        end
      end
    end
  end
end
