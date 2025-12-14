require 'json'
require 'rspec'
require 'hebrew_date'

RSpec.describe "Parasha names validation" do
  let(:file_path) { File.join(File.dirname(__FILE__), '..', 'commentary.json') }
  let(:data) { JSON.parse(File.read(file_path)) }

  # Get all valid parasha names from the hebrew_date gem
  # PARSHA_NAMES contains 60 entries, each with [Ashkenazi, Sephardi] variants
  let(:valid_parasha_names) do
    names = []
    HebrewDate::PARSHA_NAMES.each do |ashkenazi, sephardi|
      names << ashkenazi
      names << sephardi unless sephardi == ashkenazi

      # Handle "/Shira" suffix (e.g., "Beshalach/Shira" should also match "Beshalach")
      if ashkenazi.include?('/')
        names << ashkenazi.split('/').first
      end
      if sephardi.include?('/') && sephardi != ashkenazi
        names << sephardi.split('/').first
      end
    end
    names.uniq
  end

  # Special episode that doesn't follow weekly cycle
  let(:special_episodes) { ["Vezot Ha'Bracha"] }

  # Normalize name for comparison (remove apostrophes, hyphens, normalize spacing)
  def normalize_name(name)
    name.downcase
        .gsub(/['']/, '')  # Remove apostrophes
        .gsub(/-/, ' ')    # Replace hyphens with spaces
        .gsub(/\s+/, ' ')  # Normalize multiple spaces
        .strip
  end

  # Check if a title matches any valid parasha name
  def matches_parasha?(title, valid_names, special_episodes)
    # Handle special episodes
    normalized_title = normalize_name(title)
    return true if special_episodes.any? { |special| normalize_name(special) == normalized_title }

    # Handle both "Haftarah" and "Haftara" spellings with tradition suffixes
    if title =~ /^Haftara{1,2}h? (.+) \((Ashkenazim|Sephardim)\)$/
      base_title = $1
      return matches_parasha_name?(base_title, valid_names)
    end

    # Handle regular Haftarah/Haftara episodes (with or without 'h')
    if title =~ /^Haftara{1,2}h? (.+)$/
      base_title = $1
      return matches_parasha_name?(base_title, valid_names)
    end

    # Handle regular Torah portion episodes
    matches_parasha_name?(title, valid_names)
  end

  def matches_parasha_name?(title, valid_names)
    normalized_title = normalize_name(title)
    valid_names.any? { |valid_name| normalize_name(valid_name) == normalized_title }
  end

  describe "episode titles" do
    it "all Torah portion and Haftarah episodes match hebrew_date gem parasha names" do
      invalid_episodes = []

      data['items'].each do |item|
        title = item['title']

        unless matches_parasha?(title, valid_parasha_names, special_episodes)
          invalid_episodes << {
            title: title,
            normalized: normalize_name(title.sub(/^Haftarah /, '').sub(/ \((Ashkenazim|Sephardim)\)$/, ''))
          }
        end
      end

      if invalid_episodes.any?
        message = "The following episodes do not match hebrew_date gem parasha names:\n"
        invalid_episodes.each do |episode|
          message += "  - '#{episode[:title]}' (normalized: '#{episode[:normalized]}')\n"
        end
        message += "\nValid parasha names (first 10): #{valid_parasha_names.take(10).join(', ')}..."

        expect(invalid_episodes).to be_empty, message
      end
    end

    it "special episodes are properly identified" do
      # Verify Vezot Ha'Bracha exists in the data
      vezot_episodes = data['items'].select { |item| item['title'].include?("Vezot") }
      expect(vezot_episodes).not_to be_empty, "Vezot Ha'Bracha episode should exist"
    end
  end

  describe "hebrew_date gem integration" do
    it "can access PARSHA_NAMES constant" do
      expect(HebrewDate::PARSHA_NAMES).to be_an(Array)
      expect(HebrewDate::PARSHA_NAMES.length).to eq(60)
    end

    it "PARSHA_NAMES contains expected format" do
      # First parasha should be Bereshit/Bereishis
      expect(HebrewDate::PARSHA_NAMES[0]).to eq(['Bereshit', 'Bereishis'])
    end
  end
end
