# frozen_string_literal: true

# High and low
def high_and_low(numbers)
  num = numbers.split.map(&:to_i)

  "#{num.max} #{num.min}"
end
