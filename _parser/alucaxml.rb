module AlucaXML
  class Error < StandardError; end
  
  class Parser
    def self.generate_examples
      # Train on a corpus of grammatical components.
      genders     = File.readlines("_grammar/genders.txt")
      nouns       = File.readlines("_grammar/nouns.txt")
      adjectives  = File.readlines("_grammar/adjectives.txt")
      conjucation = File.readlines("_grammar/conjucation.txt")
      verb        = File.readlines("_grammar/verb.txt")
      adverb      = File.readlines("_grammar/adverb.txt")

      # Get user input for number in a list.
      gender_input      =      File.read("_input/gender_value.txt").to_s.to_i
      noun_input        =       File.read("_input/nouns_value.txt").to_s.to_i
      adjective_input   =   File.read("_input/adjective_value.txt").to_s.to_i
      conjucation_input = File.read("_input/conjucative_value.txt").to_s.to_i
      verb_input        =        File.read("_input/verb_value.txt").to_s.to_i
      adverb_input      =      File.read("_input/adverb_value.txt").to_s.to_i

      # Choose grammar components based on the input.
      chosen_gender      =          genders[gender_input].strip.to_s
      chosen_nouns       =              nouns[noun_input].strip.to_s
      chosen_adjectives  =    adjectives[adjective_input].strip.to_s
      chosen_conjucation = conjucation[conjucation_input].strip.to_s
      chosen_verb        =               verb[verb_input].strip.to_s
      chosen_adverb      =           adverb[adverb_input].strip.to_s

# Write generated text as an xml file.
      open("brains.xml", "w") { |f|
        f.print "<grammar>
  <phrase context='BIANCA:'>
    <gender>#{chosen_gender}</gender>
    <noun>#{chosen_nouns}</noun>
    <adjective>#{chosen_adjectives}</adjective>
    <conjunction>#{chosen_conjucation}</conjunction>
    <verb>#{chosen_verb}</verb>
    <adverb>#{chosen_adverb}</adverb>
    <punctuation>.</punctuation>
  </phrase>
</grammar>"
        f.puts " "
      }
    end

    def self.parse_data
      # Require and include gem.
      require 'rexml/document'
      include REXML

      # Read in XML document
      # xmlfile = File.new("grammar.xml")
      xmlfile = File.new("brains.xml")

      xmldoc = Document.new(xmlfile)

      # Get root elements.
      root = xmldoc.root

      # Listen to a form of grammar.
      xmldoc.elements.each("grammar/phrase") { 
        |e| print e.attributes["context"] + " "
      }

      # This will output the text of the user introduction.
      xmldoc.elements.each("grammar/phrase/gender")      { |e| print e.text + " " }
      xmldoc.elements.each("grammar/phrase/noun")        { |e| print e.text + " " }
      xmldoc.elements.each("grammar/phrase/adjective")   { |e| print e.text + " " }
      xmldoc.elements.each("grammar/phrase/conjunction") { |e| print e.text + " " }
      xmldoc.elements.each("grammar/phrase/verb")        { |e| print e.text + " " }
      xmldoc.elements.each("grammar/phrase/adverb")      { |e| print e.text       }
      xmldoc.elements.each("grammar/phrase/punctuation") { |e|  puts e.text       }
    end
  end

  class ProcessData
    def self.process_data
      # Get the date.
      system("date > _date/date.txt")
  
      # Immutables
      date             = File.read("_date/date.txt").strip
      date_title       = date.tr " ", "_"
  
      ## Determining user data and user choice.
      value = File.read("_input/user/user_choice.txt").to_s.to_i
  
      user_data   = File.readlines("_data/user/candidates.txt")
      user_choice = user_data[value]
  
      ## Processing AI focused data
      ai_choice            = File.read("_data/ai/ai_choice.txt").to_s.to_i
      ai_initial_candidate = user_data[ai_choice]
      ai_search_limit      = user_data.size.to_i
  
      ## Create AI data from user data.
      ai_search_limit.times do
        if ai_choice == user_choice
          puts "The specific candidate was found. Terminating selection..."
  
          ai_data      = user_data.slice!(ai_choice)
  
          open("_data/ai/candidates.txt", "w") { |f|
            f.puts ai_data
          }
        else
          puts "The specific candidate is not found..."
        end
      end
      
      ## AI processing data.
      ai_choice            = File.read("_data/ai/ai_choice.txt").to_s.to_i
      ai_data              = File.readlines("_data/ai/candidates.txt")
      ai_search_limit      = ai_data.size.to_i
      ai_next_candidate    = ai_data[ai_choice]

      ai_search_limit.times do
        if ai_next_candidate == user_choice
          ai_final_candidate = ai_next_candidate

          puts "Candidate found, processing input..."; sleep(1)

          open("_posts/input.md", "w") { |f|
            f.puts "## #{date_title}"
            f.puts ai_final_candidate
          }
        else
          puts "Candidate is not yet found..."

          ai_choice            = File.read("_data/ai/ai_choice.txt").to_s.to_i
          ai_data              = File.readlines("_data/ai/candidates.txt")
          ai_search_limit      = ai_data.size.to_i
          ai_next_candidate    = ai_data[ai_choice]

          ai_data      = user_data.slice!(ai_choice)

          open("_data/ai/candidates.txt", "w") { |f|
            f.puts ai_data
          }
        end
      end
    end
  end
  
  class NaiveBayes
    def self.train_model
      require "naive_bayes"

      a = NaiveBayes.new(:definitely_sense,      :likely_sense,
                         :ambiguous_sense,     :likely_nonsense,
                         :definitely_nonsense,
      )

      a.db_filepath = "_data/language/bianca_expanded.nb"

      # This should create a probability of 0.181818182 being definitely nonsense or definitely sense,
      # with some room for ambiguity.

      # Definitely sense
      a.train(:definitely_sense,    "BIANCA: La cabine braun es azeoir pedecise.", "word")
      a.train(:definitely_sense,      "BIANCA: La demeure vert sont oublie vite.", "word")
      a.train(:definitely_sense, "BIANCA: Le zigner braun esa azeoir mopedecise.", "word")
      a.train(:definitely_sense,     "BIANCA: Le maizon gris es azeoir pedecise.", "word")

      # Likely sense
      a.train(:likely_sense,        "BIANCA: Azeoir pedecide es le cabine braun.", "word")
      a.train(:likely_sense,          "BIANCA: Oublie vite sont la demeure vert.", "word")
      a.train(:likely_sense,     "BIANCA: Azeoir mopedecise esa le zigner braun.", "word")
      a.train(:likely_sense,         "BIANCA: Azeoir pedecise es le maizon gris.", "word")
      a.train(:likely_sense,          "BIANCA: La oublie demeure sont vite vert.", "word")

      # Ambiguous sense
      a.train(:ambiguous_sense,    "La braun cabine es azeoir pedecise.", "word")
      a.train(:ambiguous_sense,    "Cabine es braun la pedecise aseoir.", "word")
      a.train(:ambiguous_sense,      "La vert demeure sont oublie vite.", "word")
      a.train(:ambiguous_sense, "Le braun zigner esa azeoir mopedecise.", "word")
      a.train(:ambiguous_sense,     "Le gris maizon es azeoir pedecise.", "word")

      # Likely nonsense
      a.train(:likely_nonsense,    "La aseoir cabine es pedecise braun.", "word")
      a.train(:likely_nonsense,     "Vert la demeure oublier sont vite.", "word")
      a.train(:likely_nonsense, "Brain le zigner esa azeoir mopedecise.", "word")
      a.train(:likely_nonsense,     "Gris le maizon es azeoir pedecise.", "word")

      # Definitely nonsense
      a.train(:definitely_nonsense,    "Es cabine braun la pedecise aseoir.", "word")
      a.train(:definitely_nonsense,     "Oublier sont vite vert la demeure.", "word")
      a.train(:definitely_nonsense, "Brain le zigner esa azeoir mopedecise.", "word")
      a.train(:definitely_nonsense,     "Gris le maizon es azeoir pedecise.", "word")

      # Saving training set
      a.save
    end

    def self.analyze_sentences
      require "naive_bayes"

      a = NaiveBayes.load('_data/language/bianca_expanded.nb') 

      ## Spam
      b = File.read("_posts/input.md").to_s

      result = a.classify(b)

      print "That makes #{result[0]}."
    end
  end
end
