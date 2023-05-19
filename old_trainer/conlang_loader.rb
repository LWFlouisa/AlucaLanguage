require "naive_bayes"

a = NaiveBayes.load('_data/language/bianca.nb') 

## Spam
b = File.read("_posts/input.md").to_s

result = a.classify(b)

print "That makes #{result[0]}."
