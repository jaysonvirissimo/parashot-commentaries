require 'json'
require 'rexml/document'
require 'rspec'

RSpec.describe "Commentary JSON file" do
  let(:file_path) { File.join(File.dirname(__FILE__), '..', 'commentary.json') }

  it "is valid JSON" do
    expect {
      file_content = File.read(file_path)
      JSON.parse(file_content)
    }.not_to raise_error
  end
end

RSpec.describe "Commentary RSS feed" do
  let(:file_path) { File.join(File.dirname(__FILE__), '..', 'commentary.rss') }

  it "is a well-formed RSS file" do
    file_content = File.read(file_path)
    expect {
      REXML::Document.new(file_content)
    }.not_to raise_error
  end
end
