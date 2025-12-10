require 'json'
require 'rspec'

RSpec.describe "Data integrity" do
  let(:file_path) { File.join(File.dirname(__FILE__), '..', 'commentary.json') }
  let(:data) { JSON.parse(File.read(file_path)) }

  it "has no duplicate GUIDs across all episodes" do
    guids = data['items'].map { |item| item['guid'] }
    expect(guids.uniq.length).to eq(guids.length),
      "Found duplicate GUIDs: #{guids.group_by(&:itself).select { |k, v| v.size > 1 }.keys}"
  end

  it "has no duplicate titles across all episodes" do
    titles = data['items'].map { |item| item['title'] }
    expect(titles.uniq.length).to eq(titles.length),
      "Found duplicate titles: #{titles.group_by(&:itself).select { |k, v| v.size > 1 }.keys}"
  end

  it "uses consistent GitHub URL format for all enclosures" do
    data['items'].each do |item|
      url = item['enclosure']['url']
      expect(url).to start_with('https://github.com/jaysonvirissimo/parashot-commentaries/raw/main/audio/'),
        "Invalid URL format for episode '#{item['title']}': #{url}"
      expect(url).not_to include(' '),
        "URL contains spaces for episode '#{item['title']}': #{url}"
    end
  end

  it "has matching GUID and enclosure URL for each episode" do
    data['items'].each do |item|
      expect(item['guid']).to eq(item['enclosure']['url']),
        "GUID and enclosure URL mismatch for episode '#{item['title']}'"
    end
  end

  it "has correct enclosure type for file extension" do
    data['items'].each do |item|
      url = item['enclosure']['url']
      type = item['enclosure']['type']

      if url.end_with?('.mp3')
        expect(type).to eq('audio/mp3'),
          "Episode '#{item['title']}' has .mp3 file but type '#{type}'"
      elsif url.end_with?('.m4a')
        expect(type).to eq('audio/mp4'),
          "Episode '#{item['title']}' has .m4a file but type '#{type}'"
      else
        fail "Unexpected file extension in URL for episode '#{item['title']}': #{url}"
      end
    end
  end

  it "has all required fields for each episode" do
    data['items'].each do |item|
      # Required top-level fields
      expect(item).to have_key('title'), "Missing 'title' in episode"
      expect(item).to have_key('guid'), "Missing 'guid' in episode"
      expect(item).to have_key('pubDate'), "Missing 'pubDate' in episode"
      expect(item).to have_key('description'), "Missing 'description' in episode"
      expect(item).to have_key('enclosure'), "Missing 'enclosure' in episode"

      # Required enclosure fields
      expect(item['enclosure']).to have_key('url'), "Missing enclosure 'url' in episode '#{item['title']}'"
      expect(item['enclosure']).to have_key('length'), "Missing enclosure 'length' in episode '#{item['title']}'"
      expect(item['enclosure']).to have_key('type'), "Missing enclosure 'type' in episode '#{item['title']}'"

      # Non-empty values
      expect(item['title']).not_to be_empty, "Empty title in episode"
      expect(item['description']).not_to be_empty, "Empty description in episode '#{item['title']}'"
      expect(item['enclosure']['length']).not_to be_empty, "Empty length in episode '#{item['title']}'"
    end
  end
end
