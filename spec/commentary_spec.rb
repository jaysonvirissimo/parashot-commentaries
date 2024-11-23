require 'json'
require 'rexml/document'
require 'rspec'
require 'time'
require 'uri'

RSpec.describe "Commentary JSON file" do
  let(:file_path) { File.join(File.dirname(__FILE__), '..', 'commentary.json') }
  let(:audio_directory) { File.join(File.dirname(__FILE__), '..', 'audio') }

  it "is valid JSON" do
    expect {
      file_content = File.read(file_path)
      JSON.parse(file_content)
    }.not_to raise_error
  end

  it "contains plausible and correctly formatted pubDates" do
    file_content = File.read(file_path)
    data = JSON.parse(file_content)

    # Assuming all items have a 'pubDate' key
    if data['items']
      data['items'].each do |item|
        pub_date_str = item['pubDate']

        # Validate that pubDate is parseable
        expect {
          Time.rfc2822(pub_date_str)
        }.not_to raise_error, "Invalid date format: #{pub_date_str}"

        # Check if the date's day of the week matches the pubDate string
        parsed_date = Time.rfc2822(pub_date_str)
        expected_day_of_week = parsed_date.strftime('%a')
        actual_day_of_week = pub_date_str.split(',').first.strip

        if expected_day_of_week != actual_day_of_week
          raise "Incorrect day of the week in pubDate: #{pub_date_str}. Expected day: #{expected_day_of_week}, but got: #{actual_day_of_week}"
        end

        # Check if the date is plausible (reasonable range)
        now = Time.now
        ten_years_ago = now - (10 * 365 * 24 * 60 * 60) # 10 years ago
        five_years_from_now = now + (5 * 365 * 24 * 60 * 60) # 5 years into the future

        expect(parsed_date).to be_between(ten_years_ago, five_years_from_now),
          "Implausible date: #{pub_date_str}. Should be between #{ten_years_ago.rfc2822} and #{five_years_from_now.rfc2822}"
      end
    end
  end

  it "has corresponding audio files for each episode" do
    file_content = File.read(file_path)
    data = JSON.parse(file_content)

    if data['items']
      data['items'].each do |item|
        enclosure_url = item['enclosure']['url']
        parsed_uri = URI.parse(enclosure_url)
        file_name = File.basename(parsed_uri.path)
        local_file_path = File.join(audio_directory, file_name)

        # Corrected expect syntax
        expect(File.exist?(local_file_path)).to eq(true), "Audio file not found: #{local_file_path}"

        # Verify that the length in bytes matches the actual file size
        expected_length = item['enclosure']['length'].to_i
        actual_length = File.size(local_file_path)

        expect(actual_length).to eq(expected_length), "Incorrect file length for #{file_name}. Expected: #{expected_length}, but got: #{actual_length}"
      end
    end
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
