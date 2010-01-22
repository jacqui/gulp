class Gulp
  class Document
    ALLOWED_PHRASE_LENGTHS = [2,3,4]
    STOPWORDS = %w(a an and except from has in into is made of one that the these this to with)
    attr_reader :word_count, :phrase_counts
  
    def initialize(name, corpus)
      @name = name
      @corpus = corpus
      @word_count = 0
      @phrase_counts = Hash.new(0)
    end
  
    def self.new_from_xml_file(path)
      obj = new
      extractor = XMLTextExtractor.new(self)
      Nokogiri::XML::SAX::Parser.new(extractor).parse(input)
    end
  
    def add_text(text)
      strings = chunk_text(preprocess_text(text))
    
      strings.each do |string|
        words = string.split(/\s+/)
        next if words.size == 0
      
        @word_count += words.size
      
        ALLOWED_PHRASE_LENGTHS.each do |length|
          final_start_position = words.size - length
          (0..final_start_position).each do |start_position|
            sub_phrase_words = words.slice(start_position, length)
          
            next if STOPWORDS.include?(sub_phrase_words.first.downcase) || STOPWORDS.include?(sub_phrase_words.last.downcase)
          
            sub_phrase = sub_phrase_words.join(' ')
            phrase_counts[sub_phrase] += 1
          end
        end
      end
    end
  
    def preprocess_text(text)
      # remove parentheticals
      text.gsub!(/\(.+?\)/, ' ')
      text.gsub!(/\[.+?\]/, ' ')
      text.gsub!(/\{.+?\}/, ' ')
  
      # remove funky chars
      text.gsub!(/[^ a-zA-Z0-9-]/,'')
    end
  
    def chunk_text(text)
      text.split(/\.|,|:|;/).compact.map{|s| s.gsub(/^\s+|\s+$/,'').gsub(/\s+/, ' ')}.reject{|s| s =~ /^\s*$/}
    end
  end
  
  class XMLTextExtractor < Nokogiri::XML::SAX::Document
    def initialize(phrase_extractor)
      super
      @phrase_extractor = phrase_extractor
    end

    def characters(text)
      @phrase_extractor.add_text(text)
    end
  end
end