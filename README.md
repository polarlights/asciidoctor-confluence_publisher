# Asciidoctor-ConfluencePublisher

Asciidoctor-ConfluencePublisher is a command line tool that parse asciidoc files,
generate confluence compatible html and upload the content and attachment to confluence.

This repo inspired by [confluence-publisher](https://github.com/confluence-publisher/confluence-publisher)

**It requires Ruby 2.x. works for Confluence 6+.**

## Installation

```ruby
gem install asciidoctor-confluence_publisher
```

## Usage

### configuration
`asciidoctor-confluence_publisher` is built on asciidoctor gem, so the gem is compatible with
all the arguments of asciidoctor. 

The configuration of confluence can be set via attribute(`-a attr=attr_value`), or set via system environment.
The attribute or environment are:


attribute name | environment variable | note | required
--- | --- | --- | ---
confluence_host | CONFLUENCE_HOST | confluence host with protocol. | Y |
space | SPACE | confluence page space. | Y |
username | CONFLUENCE_USERNAME | confluence username. | Y |
password | CONFLUENCE_PASSWORD | confluence password. | Y |
ancestor_id | ANCESTOR_ID | page ancestor id. | Y |
proxy | CONFLUENCE_PROXY | confluence http proxy. | N |
skip_verify_ssl | - | whether skip verify ssl. | N |

It is recomanded that use environment for confluence related host, username and password, for example [autoenv](https://github.com/inishchith/autoenv)

### Run

```bash
confluence-publisher [file or directory]
```
The title of source file will be the title in confluence.

If the final argument is a file, it will only processed the single file. It will recursively process all
the source file except file starting with `_`, for directory parameter.


## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/polarlights/asciidoctor-confluence_publisher.

