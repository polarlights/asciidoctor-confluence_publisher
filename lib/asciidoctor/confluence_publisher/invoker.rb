require 'digest'

module Asciidoctor
  module ConfluencePublisher
    class Invoker
      # default template directory for asciidoctor_confluence marcos
      DEFAULT_TEMPLATE_DIR = File.expand_path("../../../../template", __FILE__)

      attr_reader :options
      def initialize(options)
        @options = options.dup
        @options[:to_file] = nil
        @options[:catalog_assets] = true

        @options[:backend] = 'xhtml5'
        @options[:template_dirs] = Array(options[:template_dirs]) << DEFAULT_TEMPLATE_DIR
        @options[:to_file] = false
        @options[:header_footer] = false
        # confluence related configuration
        attributes = options[:attributes] || {}
        attributes['confluence_host'] ||= ENV['CONFLUENCE_HOST']
        attributes['space'] ||= ENV['SPACE']
        attributes['username'] ||= ENV['CONFLUENCE_USERNAME']
        attributes['password'] ||= ENV['CONFLUENCE_PASSWORD']
        @ancestor_id = (attributes['ancestor_id'] ||= ENV['ANCESTOR_ID'])
        check_confluence_config(attributes)

        proxy = attributes[:proxy] || ENV['CONFLUENCE_PROXY']
        skip_verify_ssl = attributes['skip_verify_ssl'].to_s == 'true'
        @confluence_client = ConfluenceApi.new(attributes['confluence_host'],
                                               attributes['space'],
                                               attributes['username'],
                                               attributes['password'],
                                               skip_verify_ssl: skip_verify_ssl,
                                               proxy: proxy)
      end

      def invoke!
        input_files = options[:asciidoc_source_dir] ? Array(options[:asciidoc_source_dir]) : options[:input_files]

        input_files.map(&method(:build_file_tree)).each do |node|
          traverse_file_tree(@ancestor_id, node, &method(:convert_and_publish))
        end
      end

      private
      def convert_and_publish(ancestor_id, input_file)
        if File.file?(input_file)
          document = Asciidoctor.load_file input_file, options
          confluence_page = find_or_create_page(document.title, ancestor_id)
          process_page_content(confluence_page.id, document.title, document.content)
          process_page_attachments(confluence_page.id, [document.references[:links], document.references[:images]].flatten, File.dirname(input_file))
        else
          title = File.basename(input_file)
          confluence_page = find_or_create_page(title, ancestor_id)
        end
        confluence_page.id
      end

      def process_page_attachments(page_id, assets, source_dir)
        resource_property = 'resource_hash'
        page_resource_prop = @confluence_client.get_page_property(page_id, resource_property)
        page_attachment_hash = page_resource_prop && page_resource_prop.value || {}
        attachment_hash = @confluence_client.get_attachments(page_id).map { |attachment| [attachment.title, attachment.id] }.to_h

        has_asset_updated = false
        assets.each do |link|
          next if Asciidoctor::Helpers.uriish?(link)
          source_file_dir = source_dir
          if link.is_a? ::Struct
            source_file_dir += "/#{link.imagesdir}"
          end
          file_path = File.join(source_file_dir, link.to_s)
          next if !File.exist?(file_path)
          file_md5 = Digest::MD5.hexdigest File.read(file_path)
          filename = File.basename(file_path)

          attachment_update_success = if attachment_hash.has_key?(filename)
                                        if file_md5 != page_attachment_hash[filename]
                                          @confluence_client.update_attachment(page_id, attachment_hash[filename], file_path)
                                          has_asset_updated = true
                                        end
                                      else
                                        @confluence_client.create_attachment(page_id, file_path)
                                        has_asset_updated = true
                                      end
          page_attachment_hash[filename] = file_md5 if attachment_update_success
        end

        @confluence_client.set_page_property(page_id, resource_property, page_attachment_hash) if has_asset_updated
      end

      def process_page_content(page_id, title, document_content)
        content_property = 'content_hash'
        page_hash_prop = @confluence_client.get_page_property(page_id, content_property)
        page_content_hash = page_hash_prop && page_hash_prop.value

        if (new_content_hash = Digest::MD5.hexdigest(document_content)) != page_content_hash
          @confluence_client.update_page(page_id, title, document_content)
          @confluence_client.set_page_property(page_id, content_property, new_content_hash)
        end
      end

      def check_confluence_config(attributes)
        empty_attrs = %w(confluence_host space username password ancestor_id).select do |prop|
          attr = attributes[prop]
          attr.nil? || attr.to_s.strip.length < 1
        end
        raise empty_attrs.join(', ') if empty_attrs.size > 0
      end

      def build_file_tree(root)
        node = nil
        if File.directory?(root) || File.file?(root) && File.extname(root) =~ /.(adoc|asc|asciidoc)$/
          node = Asciidoctor::ConfluencePublisher::Asciidoc.new(root)
        end
        return node if File.file?(root)

        Dir.children(root).each do |dir|
          next if dir.start_with?('.')
          child = build_file_tree(File.join(root, dir))
          node.add_child(child)
        end

        node
      end

      def traverse_file_tree(ancestor_id, root, &block)
        new_ancestor_id =  ancestor_id
        if options[:asciidoc_source_dir] != root.path
          new_ancestor_id = block.call(ancestor_id, root.path)
        end
        children = root.children
        return if children.size.zero?
        children.each do |child|
          next if !child.has_any_leaves?
          traverse_file_tree(new_ancestor_id, child, &block)
        end
      end

      def find_or_create_page(title, ancestor_id)
        confluence_pages = @confluence_client.get_pages_by_title(title).select { |page| page.contain_ancestor?(ancestor_id) }
        if confluence_pages.size > 1
          raise 'Too many duplicate page title'
        elsif confluence_pages.size == 1
          confluence_page = confluence_pages[0]
        else
          confluence_page = @confluence_client.create_page(title, '', ancestor_id)
        end
        confluence_page
      end
    end
  end
end