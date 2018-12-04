require 'elasticsearch/api'

# TracingClient is an extension of the default Elasticsearch client.
# It overrides the index method to let us avoid tagging the request body in
# case of very large index/create requsts.
#
# Other than that, it behaves the same as the default client and passes calls
# on to the parent.
#
# TracingClient is only meant to be used when also using
# Elasticsearch::Tracer::Transport, as it expects a tag_body member
module Elasticsearch
  module Tracer
    class TracingClient < ::Elasticsearch::Transport::Client

      def index(arguments = {})
        # trace this request without tagging the request body
        @transport.tag_body = false
        super
      ensure
        @transport.tag_body = true
      end
    end
  end
end
