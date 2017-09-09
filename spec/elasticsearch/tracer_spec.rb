require "spec_helper"

RSpec.describe Elasticsearch::Tracer do
  it "has a version number" do
    expect(Elasticsearch::Tracer::VERSION).not_to be nil
  end
end
