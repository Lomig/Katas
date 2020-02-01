# Class representing entities shown on the map.
class Entity
  attr_reader :type, :position, :radius

  def initialize(type, x, y, radius)
    @type = type.downcase.to_sym
    @position = Point2.new(x, y)
    @radius = radius
  end
end
