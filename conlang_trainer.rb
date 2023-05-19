require "naive_bayes"

a = NaiveBayes.new(:definitely_sense,      :likely_sense,
                   :ambiguous_sense,     :likely_nonsese,
                   :definitely_nonsense,
)

a.db_filepath = "_data/language/bianca.nb"

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
