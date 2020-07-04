require 'asciidoctor/confluence_publisher'
require 'asciidoctor/cli'

module Asciidoctor
  module ConfluencePublisher
    class Command
      def self.execute(args)
        options = Asciidoctor::Cli::Options.new

        unless args != ['-v'] && (args & ['-V', '--version']).empty?
          $stdout.write %(Asciidoctor Confluence #{Asciidoctor::ConfluencePublisher::VERSION} using )
          options.print_version
          exit 0
        end

        orig_args = args.dup
        # if the parameter is a directory, it will set to the root of source_file
        source_dir = nil
        2.times do
          result = options.parse! args
          break unless result.is_a? Integer

          can_retry = false
          if args.size == 1
            source_dir = args.first
            args = convert_directory_to_files(source_dir, orig_args)
            can_retry = true
          end
          exit result unless can_retry
        end

        options[:asciidoc_source_dir] = source_dir
        invoker = Asciidoctor::ConfluencePublisher::Invoker.new options
        GC.start
        invoker.invoke!
      end

      private

      def self.convert_directory_to_files(file, orig_args)
        fstat = ::File.stat file
        if fstat.ftype == 'directory' && (input_files = parse_directory_files(file)).size > 0
          orig_args.reject! { |_arg| file == _arg }
          orig_args.concat input_files
          return orig_args
        end
      end

      # hack asciidoctor to support folder
      def self.parse_directory_files(directory)
        infiles = []
        file = File.join(directory, "**/*.{asc,adoc,asciidoc}")
        if (matches = ::Dir.glob file).size > 0
          infiles = matches
        end
        # reject file start with "_", in conversion it is a included file
        infiles.reject! { |file| File.basename(file).start_with?("_")}
        infiles
      end
    end
  end
end
