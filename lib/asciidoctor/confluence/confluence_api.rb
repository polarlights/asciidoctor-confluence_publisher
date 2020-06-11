require 'rest-client'
require 'json'

module Asciidoctor
  module Confluence
    class ConfluenceApi
      attr_reader :host, :space, :username, :ancestor_id

      def initialize(host, options)
      end

      def create_page(space, title, content)
        url = host + '/rest/api/content?expand=version'
        payload = {
            title: title,
            type: 'page',
            space: space,
            body: {
                storage: {
                    value: content,
                    representation: 'storage'
                }
            }
        }
      end

      def update_page(page_id, title: '', content: '', version: '')
        url = host + "/rest/api/content/#{page_id}"
        payload = {
            title: title,
            type: 'page',
            body: {
                storage: {
                    value: content,
                    representation: 'storage'
                }
            },
            version: version
        }
      end

      def get_page_by_id(page_id)
        url = host + "/rest/api/content/#{page_id}?expand=version"
      end

      def get_page_by_title(space, title)
        url = host + '/rest/api/content?expand=space'
        payload = {
            type: 'page',
            spaceKey: space,
            title: title
        }
      end

      def get_attachments(page_id)
        url = host + "/rest/api/content/#{page_id}/child/attachment?expand=metadata.properties,version"
      end

      def update_attatchment(page_id, filename, file_path)
        url = host + "/rest/api/content/#{page_id}/child/attachment?expand=metadata.properties,version"
        payload = {

        }
      end

      def delete_attatchment(attachment_id)
      end

      def set_page_property(owner_id, key, value)
        url = host + "/rest/api/content/#{owner_id}/property/#{key}"
        payload = {
            value: value,
            version: ''
        }
      end

      def get_page_property(owner_id, key)
      end

      def remove_page_property(owner_id, key)
      end

      private
      def send_request(mthd, url, req_payload = {}, req_headers = {}, req_options = {})
        headers = req_headers.dup
        payload = req_payload.dup
        options = req_options.dup
        options[:timeout] = 30
        if %w(get delete).include? mthd.to_s
          payload = {}
          headers.merge!({ params: params })
        elsif req_headers.empty?
          headers = { content_type: 'application/json' }
        end

        RestClient::Request.execute(
            method: mthd,
            url: url,
            payload: payload.to_json,
            headers: headers,
            timeout: 30) do |resp, req, re|
          begin
            if resp.code.between?(200, 399)
              return { success: true, code: resp.code, body: resp.body && JSON.parse(resp.body) }
            else
              return { success: false, code: resp.code, message: JSON.parse(resp.body) }
            end
          rescue => error
            return { success: false, code: 500, message: error.message }
          end
        end
      rescue => error
        return { success: false, code: 500, message: error.message }
      end

      def basic_auth_val
        Base64.strict_encode64 "#{@username}:#{@password}"
      end
    end
  end
end
