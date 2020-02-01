# Class representing a position as a vector.
class Point2
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def +(other)
    Point2.new(@x + other.x, @y + other.y)
  end

  def -(other)
    Point2.new(@x - other.x, @y - other.y)
  end

  def *(other)
    Point2.new(@x * other, @y * other)
  end

  def /(other)
    Point2.new(@x / other, @y / other)
  end

  def length
    Math.sqrt(@x**2 + @y**2)
  end

  def norm
    length > 0.1 ? self / length : Point2.new(0, 0)
  end

  def distance_to_position (other_point2)
    (self - other_point2).length
  end
end
