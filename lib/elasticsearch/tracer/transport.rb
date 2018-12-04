module Elasticsearch
  module Tracer
    class Transport
      attr_reader :tracer, :active_span, :wrapped

      def initialize(tracer: OpenTracing.global_tracer, active_span: nil, transport:)
        @tracer = tracer
        @active_span = active_span
        @wrapped = transport
      end

      def perform_request(method, path, params={}, body=nil, headers=nil)
        span = tracer.start_span(method,
                                 child_of: active_span.respond_to?(:call) ? active_span.call : active_span,
                                 tags: {
                                  'component' => 'elasticsearch-ruby',
                                  'span.kind' => 'client',
                                  'http.method' => method,
                                  'http.url' => path,
                                  'db.type' => 'elasticsearch',
                                  'db.statement' => MultiJson.dump(body),
                                  'elasticsearch.params' => URI.encode_www_form(params)
                                 })

        response = @wrapped.perform_request(method, path, params, body, headers)
        span.set_tag('http.status_code', response.status)

        response
      rescue Exception => e
        if span
          span.set_tag('error', true)
          span.log(event: 'error', :'error.object' => e)
        end
        raise
      ensure
        span.finish if span
      end
    end
  end
end
