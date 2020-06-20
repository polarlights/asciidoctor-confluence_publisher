require 'test_helper'
require 'webmock/minitest'

class ConfluenceApiTest < MiniTest::Test
  def setup
    @space = 'space'
    @confluence_api = Asciidoctor::ConfluencePublisher::ConfluenceApi.new('https://example.com', @space, 'username', 'password')
  end

  def test_create_page_should_work
    stub_request(:post, /example.com/).
        to_return(status: 200, body: read_response('create_confluence_page'))

    title = 'test title'
    content = '<p>hello</p>'
    ancestor_id = 753665

    page = @confluence_api.create_page(title, content, ancestor_id)
    assert_equal title, page.title
    assert_equal @space, page.space.key
    assert_equal 1, page.version.number
    assert_includes page.ancestors.map(&:id), ancestor_id.to_s
  end

  def test_update_page_should_work
    stub_request(:get, /example.com/).
        to_return(status: 200, body: read_response('create_confluence_page'))
    stub_request(:put, /example.com/).
        to_return(status: 200, body: read_response('update_confluence_page'))

    title = 'another title'
    content = '<p>hello</p>'

    page = @confluence_api.update_page(45674401, title, content)
    assert_requested(:put, /example.com/, times: 1) { |req| JSON.parse(req.body)['version']['number'] == 2 }
    assert_equal title, page.title
    assert_equal @space, page.space.key
    assert_equal 2, page.version.number
  end

  def test_get_page_by_id_success
    stub_request(:get, /example.com/).
        to_return(status: 200, body: read_response('create_confluence_page'))

    title = 'test title'

    page = @confluence_api.get_page_by_id(45674401)
    assert_equal title, page.title
    assert_equal @space, page.space.key
    assert_equal 1, page.version.number
  end

  def test_get_page_by_id_not_found
    stub_request(:get, /example.com/).
        to_return(status: 404)

    page = @confluence_api.get_page_by_id(45674401)
    assert_nil page
  end

  def test_get_pages_by_title_without_match_should_return_blank_array
    stub_request(:get, /example.com/).
        to_return(status: 200, body: read_response('confluence_page_find_by_title_no_match'))

    pages = @confluence_api.get_pages_by_title('haha')
    assert_empty pages
  end

  def test_get_pages_by_title_match_should_return_blank_array
    stub_request(:get, /example.com/).
        to_return(status: 200, body: read_response('confluence_page_find_by_title_match'))

    pages = @confluence_api.get_pages_by_title('haha')
    refute_empty pages
  end

  def test_create_attachment_should_success
    stub_request(:post, /example.com/).
        to_return(status: 200, body: read_response('create_page_attachment'))
    file_path = '/tmp/LICENSE.txt'
    File.open(file_path, 'w') { |f| f.puts 'abc' }

    attachment = @confluence_api.create_attachment(1, file_path)
    assert_requested(:post, /example.com/, times: 1) do |req|
      req.headers['X-Atlassian-Token'] == 'nocheck' &&
          req.headers['Content-Type'] =~ /^multipart\/form-data/
    end
    assert_equal File.basename(file_path), attachment.title
  end

  def test_update_attachment_should_success
    stub_request(:post, /example.com/).
        to_return(status: 200, body: read_response('update_page_attachment'))
    file_path = '/tmp/LICENSE.txt'
    File.open(file_path, 'w') { |f| f.puts 'abcd' }

    attachment = @confluence_api.update_attachment(1, 1, file_path)
    assert_requested(:post, /example.com/, times: 1) do |req|
      req.headers['X-Atlassian-Token'] == 'nocheck' &&
          req.headers['Content-Type'] == 'multipart/form-data'
    end
    assert_equal File.basename(file_path), attachment.title
  end

  def test_get_attachments_should_success
    stub_request(:get, /example.com/).
        to_return(status: 200, body: read_response('get_page_attachment'))

    attachments = @confluence_api.get_attachments(1)
    refute_empty attachments
  end

  def test_set_page_property_success
    stub_request(:get, /example.com/).
        to_return(status: 404)
    stub_request(:put, /example.com/).
        to_return(status: 200, body: read_response('update_page_property'))

    key = 'resource-hash'
    value = {
        "attr1" => "attr1",
        "attr2" => "attr2"
    }
    property = @confluence_api.set_page_property(1, key, value)
    assert_equal key, property.key
    assert_equal value, property.value
    assert_equal 1, property.version.number
  end

  def test_get_page_property_success
    stub_request(:get, /example.com/).
        to_return(status: 200, body: read_response('update_page_property'))

    key = 'resource-hash'
    property = @confluence_api.get_page_property(1, key)
    refute_nil property
    refute_nil property.key
    refute_nil property.value
    refute_nil property.version
  end


  def test_remove_page_property_success
    stub_request(:delete, /example.com/).
        to_return(status: 204)

    key = 'resource-hash'
    result = @confluence_api.remove_page_property(1, key)
    assert result[:success]
  end

  private
  def read_response(filename)
    current_dir = File.dirname(__FILE__)
    File.read("#{current_dir}/response/#{filename}.json")
  end
end