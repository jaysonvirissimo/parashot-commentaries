require 'json'
require 'rexml/document'
require 'rspec'
require 'time'

RSpec.describe "Commentary JSON file" do
  let(:file_path) { File.join(File.dirname(__FILE__), '..', 'commentary.json') }

  it "is valid JSON" do
    expect {
      file_content = File.read(file_path)
      JSON.parse(file_content)
    }.not_to raise_error
  end

  it "contains plausible and correctly formatted pubDates" do
    file_content = File.read(file_path)
    data = JSON.parse(file_content)

    data['items'].each do |item|
      pub_date_str = item['pubDate']

      # Check that the pubDate is in the correct RFC 2822 format and parseable
      parsed_date = nil
      expect {
        parsed_date = Time.rfc2822(pub_date_str)
      }.not_to raise_error, "Invalid date format: #{pub_date_str}"

      # Validate that the day of the week in pubDate matches the parsed date
      expected_day_of_week = parsed_date.strftime('%a')
      actual_day_of_week = pub_date_str.split(',').first.strip
      expect(actual_day_of_week).to eq(expected_day_of_week),
        "Incorrect day of the week in pubDate: #{pub_date_str}. Expected: #{expected_day_of_week}, but got: #{actual_day_of_week}"

      # Check if the date is within a reasonable range (10 years in the past to 5 years in the future)
      now = Time.now
      ten_years_ago = now - (10 * 365 * 24 * 60 * 60)
      five_years_from_now = now + (5 * 365 * 24 * 60 * 60)

      expect(parsed_date).to be_between(ten_years_ago, five_years_from_now),
        "Implausible date: #{pub_date_str}. Should be between #{ten_years_ago.rfc2822} and #{five_years_from_now.rfc2822}"
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
