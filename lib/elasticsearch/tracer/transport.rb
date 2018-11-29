module Elasticsearch
  module Tracer
    class Transport
      attr_reader :tracer, :active_span, :wrapped

      def initialize(tracer: OpenTracing.global_tracer, active_span: nil, transport:, db_statement_limit: nil)
        @tracer = tracer
        @active_span = active_span
        @wrapped = transport
        @db_statement_limit = db_statement_limit
      end

      def perform_request(method, path, params={}, body=nil)
        statement = MultiJson.dump(body)
        statement = statement[0...@db_statement_limit] if @db_statement_limit

        span = tracer.start_span(method,
                                 child_of: active_span.respond_to?(:call) ? active_span.call : active_span,
                                 tags: {
                                  'component' => 'elasticsearch-ruby',
                                  'span.kind' => 'client',
                                  'http.method' => method,
                                  'http.url' => path,
                                  'db.type' => 'elasticsearch',
                                  'db.statement' => statement,
                                  'elasticsearch.params' => URI.encode_www_form(params)
                                 })

        response = @wrapped.perform_request(method, path, params, body)
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
