# frozen_string_literal: true

# Get the Middle Character
def get_middle(str)
  l = str.length
  return str.chars[l / 2] if l.odd?

  str.chars[l / 2 - 1] + str.chars[l / 2]
end
