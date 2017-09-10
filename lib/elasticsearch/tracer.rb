require 'elasticsearch'

require "elasticsearch/tracer/version"
require "elasticsearch/tracer/transport"

module Elasticsearch
  module Tracer
    class << self
      def instrument(tracer: OpenTracing.global_tracer, active_span: nil, transport:)
        Elasticsearch::Tracer::Transport.new(tracer: tracer, active_span: active_span, transport: transport)
      end
    end
  end
end
