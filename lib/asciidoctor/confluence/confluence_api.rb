require 'rest-client'
require 'json'

module Asciidoctor
  module Confluence
    class ConfluenceApi
      attr_reader :host, :space, :username

      def initialize(host, space, username, password, skip_verify_ssl: false, proxy: nil)
        @host = host
        @space = space
        @username = username
        @password = password
        @skip_verify_ssl = skip_verify_ssl
        RestClient.proxy = proxy if proxy
      end

      # create a confluence page
      #
      def create_page(title, content, ancestor_id)
        url = host + '/rest/api/content?expand=version,ancestors,space'
        payload = {
            title: title,
            type: 'page',
            space: {key: space},
            ancestors: Array(ancestor_id).map { |ans_id| { id: ans_id } },
            body: {
                storage: {
                    value: content,
                    representation: 'storage'
                }
            }
        }

        req_result = send_request(:post, url, payload, default_headers)
        Model::Page.new req_result[:body] if req_result[:success]
      end

      def update_page(page_id, title, content)
        url = host + "/rest/api/content/#{page_id}"
        current_page = get_page_by_id(page_id)
        payload = {
            title: title,
            type: 'page',
            body: {
                storage: {
                    value: content,
                    representation: 'storage'
                }
            },
            version: {
                number: current_page.version.number + 1
            }
        }

        req_result = send_request(:put, url, payload, default_headers)
        Model::Page.new req_result[:body] if req_result[:success]
      end

      def get_page_by_id(page_id)
        url = host + "/rest/api/content/#{page_id}"
        payload = {
            expand: 'version,space,ancestors'
        }
        req_result = send_request(:get, url, payload, default_headers)
        Model::Page.new(req_result[:body]) if req_result[:success]
      end

      def get_pages_by_title(title)
        url = host + '/rest/api/content'
        payload = {
            type: 'page',
            spaceKey: space,
            title: title,
            expand: 'ancestors,space,version'
        }

        start =0
        limit = 30
        result = []
        loop do
          pageable = { start: start, limit: limit}
          req_result = send_request(:get, url, payload.merge(pageable), default_headers)
          no_data = true
          if req_result[:success] && req_result[:body]['size'] > 0
            result.concat req_result[:body]['results'].map { |page| Model::Page.new(page) }
            no_data = req_result[:body]['size'] < req_result[:body]['limit']
          end
          break if no_data
          start += 1
        end
        result
      end

      def get_attachments(page_id)
        url = host + "/rest/api/content/#{page_id}/child/attachment"
        start = 0
        limit = 50

        result = []
        loop do
          payload = { start: start, limit: limit}
          req_result = send_request(:get, url, payload, default_headers)
          no_data = true
          if req_result[:success] && req_result[:body]['size'] > 0
            result.concat req_result[:body]['results'].map { |attachment| Model::Attachment.new attachment }
          end

          break if no_data
          start += 1
        end
        result
      end

      def create_attachment(page_id, file_path)
        url = host + "/rest/api/content/#{page_id}/child/attachment"
        payload = {
            file: File.new(file_path, 'rb')
        }
        header = {
            x_atlassian_token: 'nocheck'
        }

        req_result = send_request(:post, url, payload, default_headers.merge(header), multipart: true)
        Model::Attachment.new(req_result[:body]) if req_result[:success]
      end

      def update_attachment(page_id, attachment_id, file_path)
        url = host + "/rest/api/content/#{page_id}/child/attachment/#{attachment_id}/data"
        payload = {
            file: File.new(file_path, 'rb')
        }
        header = {
            x_atlassian_token: 'nocheck',
            content_type: 'multipart/form-data'
        }

        req_result = send_request(:post, url, payload, default_headers.merge(header))
        Model::Attachment.new(req_result[:body]) if req_result[:success]
      end

      def set_page_property(owner_id, key, value)
        url = host + "/rest/api/content/#{owner_id}/property/#{key}?expand=version"
        current_property = get_page_property(owner_id, key)
        payload = {
            value: value,
            version: {
                number: (current_property && current_property.version.number).to_i + 1
            }
        }

        req_result = send_request(:put, url, payload, default_headers)
        Model::Property.new req_result[:body] if req_result[:success]
      end

      def get_page_property(owner_id, key)
        url = host + "/rest/api/content/#{owner_id}/property/#{key}"
        payload = {
            expand: 'version'
        }

        begin
          req_result = send_request(:get, url, payload, default_headers)
          Model::Property.new req_result[:body] if req_result[:success]
        rescue => e
        end
      end

      def remove_page_property(owner_id, key)
        url = host + "/rest/api/content/#{owner_id}/property/#{key}"
        payload = {}

        send_request(:delete, url, payload, default_headers)
      end

      private
      def default_headers
        {
            authorization: "Basic #{basic_auth_val}",
            accept: 'application/json',
            content_type: 'application/json'
        }
      end

      def send_request(mthd, url, req_payload = {}, req_headers = {}, req_options = {})
        headers = req_headers.dup
        payload = req_payload.dup
        options = req_options.dup
        options[:timeout] = 30
        if %w(get delete).include? mthd.to_s
          headers.merge!({ params: payload })
          payload = {}
        elsif req_headers.empty?
          headers = { content_type: 'application/json' }
        end

        if req_options[:multipart]
          headers.delete(:content_type)
        else
          payload = payload.to_json
        end

        request_params = {
            method: mthd,
            url: url,
            payload: payload,
            headers: headers,
            timeout: 30
        }
        request_params[:verify_ssl] = false if @skip_verify_ssl

        RestClient::Request.execute(request_params) do |resp, _, _|
          begin
            if resp.code.between?(200, 399)
              return { success: true, code: resp.code, body: resp.body.length > 1 && JSON.parse(resp.body) }
            elsif resp.code == 401
              raise RuntimeError, 'invalid username or password, please confirm it.'
            else
              raise RuntimeError, "send request to confluence failed, code: #{resp.code}, error: #{resp.body}"
            end
          rescue => error
            raise RuntimeError, "send request to confluence failed, code: #{resp.code}, error: #{error.message}"
          end
        end
      end

      def basic_auth_val
        Base64.strict_encode64 "#{@username}:#{@password}"
      end
    end
  end
end
