# AlucaLanguage
Functions contained and limited into a module. For website style, I chose the colors of my science fiction universe, as it's set in a French and Japanese controlled version of the Rocky Mountains.

## Run On USB
You can ran this form of machine learning on a thumb drive.

## Video Introduction
<iframe width="560" height="315" src="https://www.youtube.com/embed/XKYK0KvQMXM" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

## Setting Grammatical Values
Set each grammar component to the value of 0-4: Gender, Noun, Adjective, Conjuction, Verb, Adverb.

## Parser Module
Before training the examples, I use an automated text parser to create training examples.

~~~ruby
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
end
~~~

## Domain Specific XML Grammar
The result is an automated creation of a human-like training example.

~~~xml
<grammar>
  <phrase context='BIANCA:'>
    <gender>Le</gender>
    <noun>maizon</noun>
    <adjective>gris</adjective>
    <conjunction>es</conjunction>
    <verb>azeoir</verb>
    <adverb>pedecise</adverb>
    <punctuation>.</punctuation>
  </phrase>
</grammar> 
~~~

## How The Training Set Is Constructed
~~~ruby
require "naive_bayes"

require 'humanist_errors'
include HumanistErrors

with_human_errors do
  a             = NaiveBayes.new(:sense, :nonsense)
  a.db_filepath = "_data/language/bianca.nb"

  ## Spam
  a.train(:sense,    "BIANCA: La cabine braun es azeoir pedecise.", "word")
  a.train(:sense,      "BIANCA: La demeure vert sont oublie vite.", "word")
  a.train(:sense, "BIANCA: Le zigner braun esa azeoir mopedecise.", "word")
  a.train(:sense,     "BIANCA: Le maizon gris es azeoir pedecise.", "word")

  ## Not Spam
  a.train(:nonsense,    "BIANCA: es azeoir pedecise. La cabine braun", "word")
  a.train(:nonsense,    "BIANCA: cabine braun es azeoir pedecise. La", "word")
  a.train(:nonsense,    "BIANCA: La cabine braun es azeoir pedecise.", "word")
  a.train(:nonsense,    "BIANCA: pedecise. La cabine braun es azeoir", "word")
  a.train(:nonsense,    "BIANCA: azeoir pedecise. La cabine braun es", "word")
  a.train(:nonsense,      "BIANCA: sont oublie vite. La demeure vert", "word")
  a.train(:nonsense,      "BIANCA: vert sont oublie vite. La demeure", "word")
  a.train(:nonsense,      "BIANCA: demeure vert sont oublie vite. La", "word")
  a.train(:nonsense,      "BIANCA: vite. La demeure vert sont oublie", "word")
  a.train(:nonsense,      "BIANCA: oublie vite. La demeure vert sont", "word")
  a.train(:nonsense, "BIANCA: azeoir mopedecise. Le zigner braun esa", "word")
  a.train(:nonsense, "BIANCA: esa azeoir mopedecise. Le zigner braun", "word")
  a.train(:nonsense, "BIANCA: braun esa azeoir mopedecise. Le zigner", "word")
  a.train(:nonsense, "BIANCA: zigner braun esa azeoir mopedecise. Le", "word")
  a.train(:nonsense,     "BIANCA: Le maizon gris es azeoir pedecise.", "word")
  a.train(:nonsense,     "BIANCA: pedecise. Le maizon gris es azeoir", "word")
  a.train(:nonsense,     "BIANCA: es azeoir pedecise. Le maizon gris", "word")

  a.save
end
~~~

## Take It For a Test Drive
Once you feel confident about the code above, feel free to test drive it:

~~~sh
git clone https://github.com/LWFlouisa/AlucaLanguage.git
~~~
