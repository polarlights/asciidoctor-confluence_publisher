require_relative 'lib/asciidoctor/confluence_publisher/version'

Gem::Specification.new do |spec|
  spec.name          = "asciidoctor-confluence_publisher"
  spec.version       = Asciidoctor::ConfluencePublisher::VERSION
  spec.authors       = ["polarlights"]
  spec.email         = ["godhuyang@hotmail.com"]

  spec.summary       = %q{Parse asciidoc and publish the document to confluence.}
  spec.description   = %q{Asciidoctor-Confluence parse asciidoc and publish the document to confluence.}
  spec.homepage      = "https://github.com/polarlights/asciidoctor-confluence_publisher"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.0.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage + '/releases'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.executables   = ['confluence-publisher']
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'asciidoctor', '~> 2.0.0'
  spec.add_runtime_dependency 'haml', '~> 5.1.0'
  spec.add_runtime_dependency 'rest-client', '~> 2.1.0'

  spec.add_development_dependency 'webmock', '~> 3.8.0'
end
