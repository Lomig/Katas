# frozen_string_literal: true

# Each_with_index
# The simplest way to think about the issue
# Let's try to evolve from that, shall we?
def unique_in_order_v0(iterable)
  result = []
  iterable = iterable.chars if iterable.is_a? String

  iterable.each_with_index do |element, index|
    result << element if index.zero? || (element != iterable[index - 1])
  end

  result
end

# Inject / Reduce
#
# Inject takes its object argument, and adds it to the block as an argument.
# The block value will take the place of this object next iteration.
# When the iteration is finished, the injected object is returned.
#
# respond_to? checks if the method exists for the class. We don't care that iterable is a string,
# we care that we can use .chars on it - Now it can work on classes that inherits from String too!
#
# next exits a block and returns its argument as the value of the block - like return does in a method.
def unique_in_order_v1(iterable)
  iterable = iterable.chars if iterable.respond_to?(:chars)
  iterable.inject([]) do |result, c|
    # The block returns result
    next result if c == result.last

    # The block returns the new result including c
    result << c
  end
end

# Each_with_object
# Very alike "inject", the only difference being that the object given as an
# argument stays the same during the whole iteration:
# it's not replaced by the block value.
# The order of the block arguments is different to.
def unique_in_order_v2(iterable)
  iterable = iterable.chars if iterable.respond_to?(:chars)
  iterable.each_with_object([]) do |c, result|
    # No need to return anything
    next if c == result.last

    # We include c in a, but we don't care what the block returns
    result << c
  end
end

# Chunk
# Applied on example_var, it will return arrays of:
#   first: the result of the block on the first next element of example_var
#   last: an array of following elements of example_var that match this result.
# With this challenge and this block, it returns all elements that shows more than once in a row.
#
# &:itself is the equivalent of { |x| x }
# &:first is the equivalent of { |x| x.first }
def unique_in_order_v3(iterable)
  iterable = iterable.chars if iterable.respond_to?(:chars)
  iterable.chunk(&:itself).map(&:first)
end
