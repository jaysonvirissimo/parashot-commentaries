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

# Split the words across multiple PLS files
lexicons_dir = File.join(File.dirname(__FILE__), '..', 'lexicons')
number = 3
fraction = pronunciation_guide.size / number
pronunciation_guide.each_slice(fraction).to_a.each_with_index do |array, index|
  create_pls_file(File.join(lexicons_dir, "lexicon-#{index + 1}.pls"), array.to_h)
end
