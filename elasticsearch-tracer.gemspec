# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "elasticsearch/tracer/version"

Gem::Specification.new do |spec|
  spec.name          = "signalfx-elasticsearch-instrumentation"
  spec.version       = Elasticsearch::Tracer::VERSION
  spec.authors       = ["iaintshine"]
  spec.email         = ["bodziomista@gmail.com"]
  spec.license       = "Apache-2.0"

  spec.summary       = %q{Fork of ruby-elasticsearch-tracer. OpenTracing instrumentation for Ruby Elasticsearch client.}
  spec.description   = %q{}
  spec.homepage      = "https://github.com/signalfx/ruby-elasticsearch-tracer"

  spec.required_ruby_version = ">= 2.2.0"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'opentracing', '> 0.3.1'
  spec.add_dependency 'elasticsearch'

  spec.add_development_dependency "signalfx_test_tracer", ">= 0.1.3"
  spec.add_development_dependency "tracing-matchers", "~> 1.0", ">= 1.3.0"
  spec.add_development_dependency "bundler", "~> 2.1.4"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
