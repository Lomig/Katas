# frozen_string_literal: true

# Each_with_object
def anagrams_v1(wrd, words)
  words.each_with_object([]) { |w, a| a << w if wrd.chars.sort == w.chars.sort }
end

# Select
def anagrams_v2(word, words)
  words.select { |w| word.chars.sort == w.chars.sort }
end
