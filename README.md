[![Build Status](https://travis-ci.org/iaintshine/ruby-elasticsearch-tracer.svg?branch=master)](https://travis-ci.org/iaintshine/ruby-elasticsearch-tracer)

# Elasticsearch::Tracer

OpenTracing instrumentation for Ruby Elasticsearch client.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'signalfx-elasticsearch-instrumentation'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install signalfx-elasticsearch-instrumentation

## Usage

Elasticsearch gem allows you to customize transport layer (that's where the gem hooks up). To do that you simply pass `transport` argument to the client constructor, or inject it at run-time using `transport` accessor. See [Elasticsearch Transport Implementations](https://github.com/elastic/elasticsearch-ruby/tree/master/elasticsearch-transport#transport-implementations) for more info. If you use vanilla client without any modifications, that's also fine. 

The gem exposes a tracing and wrapping transport `Elasticsearch::Tracer::Transport`. To enable instrumentation of a client, leave the construction intact. Once you got the client, create an instance of `Elasticsearch::Tracer::Transport`. Pass the original `transport`, `tracer` and optionally `active_span`, an active span provider. Now the last step is to inject the tracing transport. See the example below.

```ruby
require 'elasticsearch'
require 'elasticsearch-tracer'

client = Elasticsearch::Client.new
client.transport = Elasticsearch::Tracer::Transport.new(tracer: OpenTracing.global_tracer,
                                                        active_span: -> { OpenTracing.global_tracer.active_span },
                                                        transport: client.transport)
```

If you use `Elasticsearch::Client` with default `Faraday` transport you might want to use [`Faraday::Tracer` middleware](https://github.com/iaintshine/ruby-faraday-tracer) as shown below. It injects OT context.

```ruby
require 'elasticsearch'
require 'elasticsearch-tracer'
require 'faraday/tracer'

client = Elasticsearch::Client.new do |faraday|
  faraday.use Faraday::Tracer, tracer: OpenTracing.global_tracer, span: -> { OpenTracing.global_tracer.active_span }
end

client.transport = Elasticsearch::Tracer::Transport.new(tracer: OpenTracing.global_tracer,
                                                        active_span: -> { OpenTracing.global_tracer.active_span },
                                                        transport: client.transport)
```

## Configuration Options

* `transport: Elasticsearch::Client.transport` the original transport.
* `tracer: OpenTracing::Tracer` an OT compatible tracer. Default `OpenTracing.global_tracer`
* `active_span: boolean` an active span provider. Default: `nil`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/iaintshine/ruby-elasticsearch-tracer. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the Elasticsearch::Tracer project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/iaintshine/ruby-elasticsearch-tracer/blob/master/CODE_OF_CONDUCT.md).
