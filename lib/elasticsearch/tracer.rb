require 'elasticsearch'

require "elasticsearch/tracer/version"
require "elasticsearch/tracer/transport"
require "elasticsearch/tracer/tracing_client"

module Elasticsearch
  module Tracer
    class << self
      attr_accessor :tag_body

      def instrument(tracer: OpenTracing.global_tracer, active_span: nil, transport:)
        Elasticsearch::Tracer::Transport.new(tracer: tracer, active_span: active_span, transport: transport)
      end
    end
  end
end
