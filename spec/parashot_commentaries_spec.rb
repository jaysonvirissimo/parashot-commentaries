# frozen_string_literal: true

require_relative '../lib/parashot_commentaries'

RSpec.describe ParashotCommentaries do
  describe '.matches_parasha?' do
    # Baseline tests
    it 'matches exact parasha name' do
      expect(described_class.matches_parasha?('Ki Tisa', 'Ki Tisa')).to be true
    end

    it 'matches with Haftarah prefix' do
      expect(described_class.matches_parasha?('Haftarah Tetzaveh', 'Tetzaveh')).to be true
    end

    it 'normalizes apostrophes' do
      expect(described_class.matches_parasha?("Vayak'hel", 'Vayakhel')).to be true
    end

    it 'strips tradition suffix' do
      expect(described_class.matches_parasha?('Haftarah Shemot (Ashkenazim)', 'Shemot')).to be true
    end

    it 'does not match different parashot' do
      expect(described_class.matches_parasha?('Bereshit', 'Noach')).to be false
    end

    # Special Shabbat slash suffix tests
    it 'strips slash suffix from parasha name' do
      expect(described_class.matches_parasha?('Tetzaveh', 'Tetzaveh/Zachor')).to be true
    end

    it 'strips slash suffix with Haftarah prefix' do
      expect(described_class.matches_parasha?('Haftarah Ki Tisa', 'Ki Tisa/Parah')).to be true
    end

    it 'handles Beshalach/Shira' do
      expect(described_class.matches_parasha?('Beshalach', 'Beshalach/Shira')).to be true
    end

    it 'handles Tzav/Hagadol' do
      expect(described_class.matches_parasha?('Tzav', 'Tzav/Hagadol')).to be true
    end

    it 'handles Mishpatim/Shekalim' do
      expect(described_class.matches_parasha?('Mishpatim', 'Mishpatim/Shekalim')).to be true
    end

    # Combined parashot tests
    it 'matches first part of combined parasha' do
      expect(described_class.matches_parasha?("Vayak'hel", 'Vayakhel-Pekudei')).to be true
    end

    it 'matches second part of combined parasha' do
      expect(described_class.matches_parasha?('Pekudei', 'Vayakhel-Pekudei')).to be true
    end

    it 'matches Haftarah of second part of combined parasha' do
      expect(described_class.matches_parasha?('Haftarah Pekudei', 'Vayakhel-Pekudei')).to be true
    end

    # Combined parashot with slash suffix
    it 'matches combined parasha with slash suffix' do
      expect(described_class.matches_parasha?("Vayak'hel", 'Vayakhel-Pekudei/Hachodesh')).to be true
    end

    # Negative: slash suffix is not a parasha
    it 'does not match the special Shabbat suffix as a parasha' do
      expect(described_class.matches_parasha?('Zachor', 'Tetzaveh/Zachor')).to be false
    end
  end
end
