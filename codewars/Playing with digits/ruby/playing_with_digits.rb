# frozen_string_literal: true

# Playing with digits
def dig_pow(number, power)
  digits = number.to_s.chars.map(&:to_i)

  sum = digits.each_with_index.inject(0) do |result, (digit, index)|
    result + digit**(power + index)
  end

  return sum / number if (sum % number).zero?

  -1
end
