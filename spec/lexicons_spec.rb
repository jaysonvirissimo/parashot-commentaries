require 'nokogiri'
require 'rspec'

lexicon_directory = File.join(File.dirname(__FILE__), '..', 'lexicons')
pls_files = Dir.glob(File.join(lexicon_directory, '*.pls'))

RSpec.describe "Lexicon PLS Files" do
  pls_files.each do |file_path|
    describe "#{File.basename(file_path)}" do
      let(:file_content) { File.read(file_path) }

      it "is a valid PLS file" do
        expect {
          Nokogiri::XML(file_content) { |config| config.strict }
        }.not_to raise_error
      end

      it "is less than the AWS Polly limit of 40,000 characters" do
        expect(file_content.size).to be <= 40_000
      end
    end
  end
end
