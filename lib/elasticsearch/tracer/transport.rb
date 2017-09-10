module Elasticsearch
  module Tracer
    class Transport
      attr_reader :tracer, :active_span, :wrapped

      def initialize(tracer: OpenTracing.global_tracer, active_span: nil, transport:)
        @tracer = tracer
        @active_span = active_span
        @wrapped = transport
      end

      def perform_request(method, path, params={}, body=nil)
        @wrapped.perform_request(method, path, params, body)
      end
    end
  end
end
