# Class representing the units present in the game.
# They can be Heroes, Minions, Towers, or Mercenaries.
class Unit
  attr_reader :id, :team, :type, :attack_range, :attack_damage, :attack_speed,
              :max_health, :movement_speed, :gold_value

  attr_accessor :health, :shield, :stun_duration, :position

  def initialize(battlefield, unit_id, team, unit_characteristics)
    @battlefield = battlefield
    @id = unit_id.to_i
    @team = team.to_i

    x, y, @attack_range, @health, @max_health, @shield, @attack_damage,
    @movement_speed, @stun_duration, @gold_value = unit_characteristics.map(&:to_i)

    @position = Point2.new(x, y)
  end

  def update_position(x, y)
    @position.x = x
    @position.y = y
  end

  def to_s
    @type.to_s.upcase
  end

  def distance_to_unit(unit)
    position.distance_to_position(unit.position)
  end

  def distance_to_unit_by_id(team, unit_id)
    unit = team.select_unit_by_id(unit_id)
    distance_to_unit(unit)
  end

  def select_unit_by_distance(team, unit_type, pos, with_range = false)
    types = unit_type == :any ? %w[@heroes @minions @towers] : [unit_translate(unit_type)]
    operator = { nearest: '<', farthest: '>' }
    selected_unit = nil
    distance = 0

    types.each do |type|
      team.instance_variable_get(type).each do |unit|
        range = with_range ? unit.attack_range : 0
        dist = @position.distance_to_position(unit.position) - range
        next unless dist.send(operator[pos], distance) || !selected_unit

        selected_unit = unit
        distance = dist
      end
    end
    [selected_unit, distance]
  end

  private

  def unit_translate(unit)
    case unit
    when :hero
      '@heroes'
    when :unit
      '@minions'
    when :tower
      '@towers'
    end
  end
end

# Class representing minions spawning on the lanes.
class Minion < Unit
  def initialize(battlefield, unit_id, team, unit_characteristics)
    super(battlefield, unit_id, team, unit_characteristics)

    @type = :unit
    @attack_speed = 0.2
  end
end

# Class representing Lane Towers,
# objective of the game.
class Tower < Unit
  def initialize(battlefield, unit_id, team, unit_characteristics)
    super(battlefield, unit_id, team, unit_characteristics)

    @type = :tower
    @attack_speed = 0.2
  end
end

# Class representing neutral enemies with gold value.
class Mercenary < Unit
  def initialize(battlefield, unit_id, team, unit_characteristics)
    super(battlefield, unit_id, team, unit_characteristics)

    @type = :groot
    @attack_speed = 0.2
  end
end

# Class representing a Hero from the Hero List;
# This is what the bot controls.
class Hero < Unit
  attr_reader :name, :max_mana, :mana_regen

  attr_accessor :mana, :cd1, :cd2, :cd3, :items,
                :current_strategy, :current_target, :last_attack

  def initialize(battlefield, unit_id, team, unit_characteristics)
    super(battlefield, unit_id, team, unit_characteristics)

    @type = :hero
    @attack_speed = 0.1

    @name, is_visible = unit_characteristics.pop(3)
    @is_visible = is_visible == '1'

    @cd1, @cd2, @cd3, @mana,
    @max_mana, @mana_regen = unit_characteristics.drop(10).map(&:to_i)

    @items = []
  end

  def visible?
    @is_visible
  end
end
