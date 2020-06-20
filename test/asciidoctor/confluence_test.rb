require "test_helper"

class Asciidoctor::ConfluenceTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Asciidoctor::ConfluencePublisher::VERSION
  end
end
