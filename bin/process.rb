require 'rexml/document'
include REXML

def sort_lexicon(file_path)
  # Read the XML file
  xml_data = File.read(file_path)
  doc = Document.new(xml_data)

  # Extract lexeme elements
  lexemes = doc.elements.to_a('//lexeme')

  # Sort and remove duplicates
  sorted_unique_lexemes = lexemes.uniq { |lex| lex.elements['grapheme'].text }.sort_by do |lex|
    lex.elements['grapheme'].text.downcase
  end

  # Rebuild the lexicon element
  lexicon = doc.root
  lexicon.elements.delete_all('lexeme')
  sorted_unique_lexemes.each { |lex| lexicon.add_element(lex) }

  # Write the new XML to the file
  indent_level = 2
  File.open(file_path, 'w') { |file| doc.write(file, indent_level) }
end

sort_lexicon(File.join(File.dirname(__FILE__), '..', 'lexicon.pls'))
