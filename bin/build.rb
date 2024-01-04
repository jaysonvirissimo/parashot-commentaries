require 'json'
require 'rexml/document'
require 'cgi'
include REXML

def create_pls_file(file_path, words)
  doc = Document.new
  doc.add_element 'lexicon', {'version' => '1.0',
                              'xmlns' => 'http://www.w3.org/2005/01/pronunciation-lexicon',
                              'alphabet' => 'ipa',
                              'xml:lang' => 'en-US'}

  words.each do |word, pronunciation|
    lexeme = Element.new('lexeme')
    grapheme = Element.new('grapheme')
    phoneme = Element.new('phoneme')

    grapheme.text = CGI.unescapeHTML(word)
    phoneme.text = pronunciation

    lexeme.add_element(grapheme)
    lexeme.add_element(phoneme)

    doc.root.add_element(lexeme)
  end

  File.open(file_path, 'w') { |file| doc.write(file, 2) }
end

file_path = File.join(File.dirname(__FILE__), '..', 'pronunciation-guide.json')
pronunciation_guide = JSON.parse(File.read(file_path))

# Splitting the words into two groups
half_size = pronunciation_guide.size / 2
first_half, second_half = pronunciation_guide.each_slice(half_size).to_a

# Creating two PLS files
lexicons_dir = File.join(File.dirname(__FILE__), '..', 'lexicons')
Dir.mkdir(lexicons_dir) unless Dir.exist?(lexicons_dir)

create_pls_file(File.join(lexicons_dir, 'lexicon1.pls'), first_half.to_h)
create_pls_file(File.join(lexicons_dir, 'lexicon2.pls'), second_half.to_h)
