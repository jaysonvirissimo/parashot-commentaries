require 'rspec'

RSpec.describe "Required audio assets" do
  let(:audio_dir) { File.join(File.dirname(__FILE__), '..', 'audio') }
  let(:intro_path) { File.join(audio_dir, 'intro.mp3') }
  let(:outro_path) { File.join(audio_dir, 'outro.mp3') }

  it "has intro.mp3 in the audio directory" do
    expect(File.exist?(intro_path)).to be true
  end

  it "has outro.mp3 in the audio directory" do
    expect(File.exist?(outro_path)).to be true
  end

  it "has a non-empty intro.mp3 file" do
    expect(File.size(intro_path)).to be > 0
  end

  it "has a non-empty outro.mp3 file" do
    expect(File.size(outro_path)).to be > 0
  end
end
