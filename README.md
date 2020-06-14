# AsciidoctorConfluence

AsciidoctorConfluence is a command line tool that parse asciidoc files,
generate confluence compatible html and upload the content and attachment to confluence.

## Installation

```ruby
gem install 'asciidoctor_confluence'
```

## Usage

`asciidoctor-confluence` is built on asciidoctor gem, so the gem is compatible with
all the arguments of asciidoctor. 

The configuration of confluence can be set via attribute(`-a attr=attr_value`), or set via system environment.
The attribute or environment are:


attribute name | environment variable | note
--- | -- | ---
confluence_host | CONFLUENCE_HOST | confluence host with protocol.  Required.
space | SPACE | confluence page space. Required.
username | CONFLUENCE_USERNAME | confluence username. Required.
password | CONFLUENCE_PASSWORD | confluence password. Required.
ancestor_id | ANCESTOR_ID | page ancestor id. Required.
proxy | CONFLUENCE_PROXY | confluence http proxy. Optional
skip_verify_ssl | - | whether skip verify ssl. Optional


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/asciidoctor-confluence.

