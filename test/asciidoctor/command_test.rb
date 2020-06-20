require "test_helper"
require 'asciidoctor/confluence_publisher/command'

class Asciidoctor::CommandTest < Minitest::Test
  def test_execute_should_generate_expected_html
    @ancestor_id = '1'
    @args = %W(-a confluence_host=https://example.com -a space=space -a username=username -a password=username -a ancestor_id=#{@ancestor_id})
    source_file = File.expand_path('source/syntax.adoc', __dir__)
    @args << source_file
    @title = 'AsciiDoc Syntax'

    create_page_response = File.read(File.expand_path('response/create_confluence_page.json', __dir__))
    @page = Asciidoctor::ConfluencePublisher::Model::Page.new JSON.parse(create_page_response)
    @parsed_page_content = File.read(File.expand_path('source/syntax_confluence', __dir__))

    confluence_api_mock = MiniTest::Mock.new
    confluence_api_mock.expect :get_pages_by_title, [], [String]
    confluence_api_mock.expect :create_page, @page  do |title, content, ancestor_id|
      title == @title && content == '' && ancestor_id == @ancestor_id
    end
    confluence_api_mock.expect :update_page, Asciidoctor::ConfluencePublisher::Model::Page  do |page_id, title, content|
      page_id == @page.id && title == @title && content == @parsed_page_content
    end
    2.times do
      confluence_api_mock.expect :get_page_property, nil, [String, String]
    end
    confluence_api_mock.expect :set_page_property, nil, [String, String, String]
    confluence_api_mock.expect :get_attachments, [], [String]


    Asciidoctor::ConfluencePublisher::ConfluenceApi.stub :new, confluence_api_mock do
      Asciidoctor::ConfluencePublisher::Command.execute @args
      confluence_api_mock.verify
    end
    assert true
  end

end
