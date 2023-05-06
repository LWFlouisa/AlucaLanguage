require "naive_bayes"

a = NaiveBayes.load('_data/language/bianca.nb') 

## Spam
b = "BIANCA: La cabine braun es azeoir pedecise."

result = a.classify(b)

print "That makes #{result[0]}."
