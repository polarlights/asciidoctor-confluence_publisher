require 'asciidoctor_confluence'
require 'asciidoctor/cli'

module Asciidoctor
  module Confluence
    class Command
      def self.execute(args)
        options = Asciidoctor::Cli::Options.new

        unless args != ['-v'] && (args & ['-V', '--version']).empty?
          $stdout.write %(Asciidoctor Confluence #{Asciidoctor::Confluence::VERSION} using )
          options.print_version
          exit 0
        end

        orig_args = args.dup
        # if the parameter is a directory, it will set to the root of source_file
        source_dir = nil
        2.times do
          result = options.parse! args
          if result.is_a? Integer
            if args.size == 1
              file = args.first
              fstat = ::File.stat file
              if fstat.ftype == 'directory' && (input_files = parse_directory_files(file)).size > 0
                source_dir = file
                orig_args.reject! { |_arg| file == _arg }
                orig_args.concat input_files
                args = orig_args
              else
                exit result
              end
            else
              exit result
            end
          end
        end

        options[:asciidoc_source_dir] = source_dir
        invoker = Asciidoctor::Confluence::Invoker.new options
        GC.start
        invoker.invoke!
        exit invoker.code
      end

      private
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
