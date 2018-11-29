require 'spec_helper'

RSpec.describe Elasticsearch::Tracer::Transport do
  let(:tracer) { Test::Tracer.new }

  describe "active span propagation" do
    let(:root_span) { tracer.start_span("root") }

    before do
      debug_transport = DebugTransport.new
      client = Elasticsearch::Client.new(transport: debug_transport)
      client.transport = Elasticsearch::Tracer::Transport.new(tracer: tracer,
                                                              active_span: -> { root_span },
                                                              transport: client.transport)
      client.search(q: 'test')
    end

    it "creates the new span with active span trace_id" do
      expect(tracer).to have_traces(1)
    end

    it "creates the new span with active span as a parent" do
      elasticsearch_span = tracer.finished_spans.last
      expect(elasticsearch_span).to be_child_of(root_span)
    end
  end

  describe "auto-instrumentation" do
    let(:body) do
      {query: {match_all: {}}}
    end

    before do
      debug_transport = DebugTransport.new
      client = Elasticsearch::Client.new(transport: debug_transport)
      client.transport = Elasticsearch::Tracer::Transport.new(tracer: tracer,
                                                              transport: client.transport)
      client.search(index: 'test_index', routing: 1, body: body)
    end

    it "creates a new span" do
      expect(tracer).to have_spans
    end

    it "sets operation_name to HTTP method name" do
      expect(tracer).to have_span("GET")
    end

    it "sets standard OT tags" do
      [
        ['component', 'elasticsearch-ruby'],
        ['span.kind', 'client']
      ].each do |key, value|
        expect(tracer).to have_span.with_tag(key, value)
      end
    end

    it "sets standard HTTP OT tags" do
      [
        ['http.method', 'GET'],
        ['http.url', 'test_index/_search'],
        ['http.status_code', 200],
      ].each do |key, value|
        expect(tracer).to have_span.with_tag(key, value)
      end
    end

    it "sets database specific OT tags" do
      [
        ['db.type', 'elasticsearch'],
        ['db.statement', MultiJson.dump(body)],
        ['elasticsearch.params', "routing=1"]
      ].each do |key, value|
        expect(tracer).to have_span.with_tag(key, value)
      end
    end
  end

  describe "exception handling" do
    let(:error) { StandardError.new }

    before do
      debug_transport = DebugTransport.new do |method, path, params, body|
        raise error
      end

      @client = Elasticsearch::Client.new(transport: debug_transport)
      @client.transport = Elasticsearch::Tracer::Transport.new(tracer: tracer,
                                                               transport: @client.transport)
    end

    it "re-raise the exception" do
      expect { @client.search(q: 'test') }.to raise_error(error)
    end

    it "sets error tag to true" do
      expect { @client.search(q: 'test') }.to raise_error do |_|
        expect(tracer).to have_span.with_tag('error', true)
      end
    end

    it "logs error event" do
      expect { @client.search(q: 'test') }.to raise_error do |_|
        expect(tracer).to have_span.with_log(event: 'error', :'error.object' => error)
      end
    end
  end

  class DebugTransport
    SuccessfullResponse = ::Elasticsearch::Transport::Transport::Response.new(200, "", {})

    def initialize(&block)
      @custom_block = block
    end

    def perform_request(method, path, params={}, body=nil, headers=nil)
      @custom_block ? @custom_block.call(method, path, params, body, headers) : SuccessfullResponse
    end
  end
end
