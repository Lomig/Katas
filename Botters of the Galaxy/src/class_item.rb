# Class representing items available to boost a Hero
# which have to be purchased.
class Item
  attr_reader :name, :cost, :damage, :move_speed,
              :max_health, :max_mana, :mana_regen

  attr_accessor :health, :mana

  def initialize(item_statistics)
    @name = item_statistics.shift
    @is_potion = item_statistics.pop == '1'

    @cost, @damage, @health, @max_health, @mana, @max_mana,
    @move_speed, @mana_regen = item_statistics.map(&:to_i)
  end

  def potion?
    @is_potion
  end
end
