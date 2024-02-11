require 'json'

RSpec.describe "Pronunciation guide" do
  let(:file_path) { File.join(File.dirname(__FILE__), '..', 'pronunciation-guide.json') }

  it "is valid JSON" do
    expect {
      file_content = File.read(file_path)
      JSON.parse(file_content)
    }.not_to raise_error
  end
end
