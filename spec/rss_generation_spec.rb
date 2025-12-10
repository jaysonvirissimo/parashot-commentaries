require 'json'
require 'nokogiri'
require 'rspec'
require 'time'

RSpec.describe "RSS feed generation" do
  let(:json_file) { File.join(File.dirname(__FILE__), '..', 'commentary.json') }
  let(:rss_file) { File.join(File.dirname(__FILE__), '..', 'commentary.rss') }
  let(:json_data) { JSON.parse(File.read(json_file)) }
  let(:rss_doc) { Nokogiri::XML(File.read(rss_file)) }

  it "contains the same number of items as commentary.json" do
    json_item_count = json_data['items'].length
    rss_item_count = rss_doc.xpath('//item').length

    expect(rss_item_count).to eq(json_item_count),
      "RSS has #{rss_item_count} items but commentary.json has #{json_item_count}"
  end

  it "sorts items by pubDate in descending order (most recent first)" do
    rss_items = rss_doc.xpath('//item')
    pub_dates = rss_items.map do |item|
      Time.rfc2822(item.xpath('pubDate').text)
    end

    # Check that dates are in descending order (most recent first)
    pub_dates.each_cons(2) do |newer, older|
      expect(newer).to be >= older,
        "Items not in descending order: #{newer} should be >= #{older}"
    end
  end

  it "includes all episode data from commentary.json" do
    rss_items = rss_doc.xpath('//item')

    # Create a map of GUID to RSS item for easy lookup
    rss_items_by_guid = {}
    rss_items.each do |rss_item|
      guid = rss_item.xpath('guid').text
      rss_items_by_guid[guid] = rss_item
    end

    json_data['items'].each do |json_item|
      # Find the corresponding RSS item by GUID
      rss_item = rss_items_by_guid[json_item['guid']]
      expect(rss_item).not_to be_nil,
        "Episode '#{json_item['title']}' (GUID: #{json_item['guid']}) not found in RSS feed"

      # Title
      expect(rss_item.xpath('title').text).to eq(json_item['title']),
        "Title mismatch for episode '#{json_item['title']}'"

      # GUID
      expect(rss_item.xpath('guid').text).to eq(json_item['guid']),
        "GUID mismatch for episode '#{json_item['title']}'"

      # PubDate
      expect(rss_item.xpath('pubDate').text).to eq(json_item['pubDate']),
        "PubDate mismatch for episode '#{json_item['title']}'"

      # Description
      expect(rss_item.xpath('description').text).to eq(json_item['description']),
        "Description mismatch for episode '#{json_item['title']}'"

      # Enclosure
      enclosure = rss_item.xpath('enclosure').first
      expect(enclosure['url']).to eq(json_item['enclosure']['url']),
        "Enclosure URL mismatch for episode '#{json_item['title']}'"
      expect(enclosure['length']).to eq(json_item['enclosure']['length']),
        "Enclosure length mismatch for episode '#{json_item['title']}'"
      expect(enclosure['type']).to eq(json_item['enclosure']['type']),
        "Enclosure type mismatch for episode '#{json_item['title']}'"
    end
  end

  it "includes all required channel metadata" do
    channel = rss_doc.xpath('//channel').first

    expect(channel.xpath('title').text).to eq(json_data['title'])
    expect(channel.xpath('link').text).to eq(json_data['link'])
    expect(channel.xpath('language').text).to eq(json_data['language'])
    expect(channel.xpath('copyright').text).to eq(json_data['copyright'])
    expect(channel.xpath('description').text.strip).to eq(json_data['description'].strip)
  end

  it "includes iTunes podcast tags" do
    channel = rss_doc.xpath('//channel').first

    # Define iTunes namespace
    itunes_ns = 'http://www.itunes.com/dtds/podcast-1.0.dtd'

    # iTunes author
    itunes_author = channel.xpath('itunes:author', 'itunes' => itunes_ns).text
    expect(itunes_author).to eq(json_data['author'])

    # iTunes summary
    itunes_summary = channel.xpath('itunes:summary', 'itunes' => itunes_ns).text.strip
    expect(itunes_summary).to eq(json_data['summary'].strip)

    # iTunes explicit
    itunes_explicit = channel.xpath('itunes:explicit', 'itunes' => itunes_ns).text
    expect(itunes_explicit).to eq(json_data['explicit'])

    # iTunes image
    itunes_image = channel.xpath('itunes:image', 'itunes' => itunes_ns).first
    expect(itunes_image['href']).to eq(json_data['image'])

    # iTunes category
    itunes_category = channel.xpath('itunes:category', 'itunes' => itunes_ns).first
    expect(itunes_category['text']).to eq(json_data['category'])

    # iTunes owner
    itunes_owner = channel.xpath('itunes:owner', 'itunes' => itunes_ns).first
    owner_name = itunes_owner.xpath('itunes:name', 'itunes' => itunes_ns).text
    owner_email = itunes_owner.xpath('itunes:email', 'itunes' => itunes_ns).text
    expect(owner_name).to eq(json_data['owner']['name'])
    expect(owner_email).to eq(json_data['owner']['email'])
  end

  it "includes atom:link self-reference" do
    channel = rss_doc.xpath('//channel').first
    atom_ns = 'http://www.w3.org/2005/Atom'

    atom_link = channel.xpath('atom:link', 'atom' => atom_ns).first
    expect(atom_link).not_to be_nil, "atom:link element not found"
    expect(atom_link['href']).to eq(json_data['link'])
    expect(atom_link['rel']).to eq('self')
    expect(atom_link['type']).to eq('application/rss+xml')
  end
end
