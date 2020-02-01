# frozen_string_literal: true

# Class Person
class Person
  def initialize(name, age)
    @name = name
    @age = age
  end

  def info
    "#{@name}s age is #{@age}"
  end
end
