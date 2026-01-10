# frozen_string_literal: true

require 'hebrew_date'
require 'json'
require 'date'
require 'time'

# Configure hebrew_date for Diaspora calendar
HebrewDate.israeli = false

module ParashotCommentaries
  # Arizona time is always UTC-7 (no DST observed)
  ARIZONA_TIMEZONE_OFFSET = '-0700'

  # Normalize parasha name for matching
  # Removes apostrophes, hyphens, normalizes spacing, and lowercases
  def self.normalize_name(name)
    name.downcase
        .gsub(/['']/, '')  # Remove apostrophes
        .gsub(/-/, ' ')    # Replace hyphens with spaces
        .gsub(/\s+/, ' ')  # Normalize multiple spaces
        .strip
  end

  # Check if an episode title matches a parasha name
  def self.matches_parasha?(episode_title, parasha_name)
    # Extract base name from episode title
    base_name = episode_title
                  .sub(/^Haftarah /, '')  # Remove "Haftarah " prefix
                  .sub(/ \((Ashkenazim|Sephardim)\)$/, '')  # Remove tradition suffix

    normalize_name(base_name) == normalize_name(parasha_name)
  end

  # Calculate same day at 06:00 Arizona time (for Sunday releases)
  # Arizona doesn't observe DST, so it's always UTC-7
  def self.same_day_0600
    now = Time.now.getlocal(ARIZONA_TIMEZONE_OFFSET)
    current_date = now.to_date

    # If we're past 06:00, target tomorrow at 06:00
    target_date = now.hour >= 6 ? current_date + 1 : current_date

    Time.new(target_date.year, target_date.month, target_date.day, 6, 0, 0, ARIZONA_TIMEZONE_OFFSET)
  end

  # Find all episodes matching a parasha name (Torah portion + Haftarah variants)
  def self.find_matching_episodes(data, parasha_name)
    data['items'].select do |item|
      matches_parasha?(item['title'], parasha_name)
    end
  end
end
