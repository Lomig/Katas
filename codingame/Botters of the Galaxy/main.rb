################################################################################
## CodinGame -- Botters of the Galaxy
##
## Debug: STDERR.puts
################################################################################
STDOUT.sync = true


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

# Class representing entities shown on the map.
class Entity
  attr_reader :type, :position, :radius

  def initialize(type, x, y, radius)
    @type = type.downcase.to_sym
    @position = Point2.new(x, y)
    @radius = radius
  end
end

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

# Class representing a team in the game;
# It has some towers, some heroes and some minions.
class Team
  attr_reader :side

  attr_accessor :heroes, :towers, :minions, :mercenaries, :gold

  def initialize(team)
    @side = team
    @gold = 0
    @heroes = []
    @towers = []
    @minions = []
    @mercenaries = []

    @units = {}
  end

  # Add a member to the team
  def populate(unit)
    @units[unit.id] = unit

    case unit.type
    when :hero
      @heroes << unit
    when :unit
      @minions << unit
    when :tower
      @towers << unit
    when :groot
      @mercenaries << unit
    end
  end

  # Select a unit by its ID
  def select_unit_by_id(unit_id)
    @units[unit_id]
  end

  # Remove all units to prepare for the next round
  def prepare_for_new_round
    @units.clear
    @heroes.clear
    @minions.clear
    @mercenaries.clear
  end
end

# Class representing the Battlefield;
# It has dimension and entities
class Battlefield
  attr_reader :teams, :entities, :shop

  attr_accessor :mercenaries

  MAX_WIDTH = 1920
  MAX_HEIGHT = 750

  def initialize(us, them)
    @entities = []
    @mercenaries = []
    @shop = []

    @us = us.side
    @them = them.side
    @neutral = 2

    @teams = Array.new(2)
    @teams[us.side] = us
    @teams[them.side] = them

    @hero_preference = %w[IRONMAN DOCTOR_STRANGE HULK VALKYRIE DEADPOOL]
  end

  def us
    @teams[@us]
  end

  def them
    @teams[@them]
  end

  def neutral
    @teams[@neutral]
  end

  def select_unit_by_id(unit_id)
    types = %w[@heroes @minions @towers @mercenaries]

    teams.each do |team|
      types.each do |type|
        team.instance_variable_get(type).each do |unit|
          return unit if unit.id == unit_id
        end
      end
    end
    nil
  end

  # Add an entity to the Battlefield
  def add_entities(entity_characteristics)
    type, x, y, radius = entity_characteristics
    @entities << Entity.new(type, x, y, radius)
  end

  # Enlist an item in the shop
  def provision_shop_with_items(item_statistics)
    @shop << Item.new(item_statistics)
  end

  # Remove all units to prepare for the next round
  def prepare_for_new_round
    @teams.each(&:prepare_for_new_round)
  end

  # Set earned gold for each team
  def count_gold
    us.gold = gets.to_i
    them.gold = gets.to_i
  end

  # Select a Hero for the game
  def select_hero
    puts @hero_preference.shift
  end

  # Initialization of the Battlefield,
  # Setting up units
  def populate
    entity_count = gets.to_i
    entity_count.times do
      unit_id, team, unit_type, *unit_charac = gets.split(' ')

      create_unit(unit_id, team, unit_type, unit_charac)
    end
  end

  # Creation and Initialization of the neutral team
  def populate_neutral_team(unit)
    @teams[@neutral] = Team.new(2) unless neutral
    @teams[@neutral].populate(unit)
  end

  # Create units each round
  def create_unit(unit_id, team, unit_type, unit_characteristics)
    unit =  case unit_type
            when 'UNIT'
              Minion.new(self, unit_id, team, unit_characteristics)
            when 'HERO'
              Hero.new(self, unit_id, team, unit_characteristics)
            when 'TOWER'
              Tower.new(self, unit_id, team, unit_characteristics)
            when 'GROOT'
              Mercenary.new(self, unit_id, team, unit_characteristics)
            end

    if unit.type == :mercenary
      populate_neutral_team(unit)
    else
      @teams[unit.team].populate(unit)
    end
  end
end

################################################################################
## Movements
################################################################################

# Class extension for possible moves
class Hero
  # Attack a target by its ID
  def attack_by_id(unit_id)
    puts "ATTACK #{unit_id}"

    @current_strategy = :attack
    @current_target = unit_id
  end

  # Attack a target acording to its distance (Nearest or Farthest)
  def attack_by_distance(unit_type, strategy = :nearest)
    target, = select_unit_by_distance(@battlefield.them, unit_type, strategy)
    @last_attack = target
    attack_by_id(target.id)

    @current_strategy = :attack
    @current_target = target.id
  end

  # Attack a target according to its position (Frontline or Backline)
  def attack_by_position(unit_type, position)
    positions = { frontline: :nearest, backline: :farthest }

    tower, = select_unit_by_distance(@battlefield.us, :tower, :nearest)
    unit, = tower.select_unit_by_distance(@battlefield.them, unit_type, positions[position])

    @last_attack = unit
    attack_by_id(unit.id)

    @current_strategy = :attack
    @current_target = unit.id
  end

  ##############################################################################
  def move_attack(destination, unit)
    puts "MOVE_ATTACK #{destination.x.round} #{destination.y.round} #{unit.id}"
  end

  ##############################################################################

  # Move towards a point
  def move_to_position(x, y)
    return false if (@position.x - x).abs < 1 && (@position.y - y).abs < 1
    puts "MOVE #{x} #{y}"
    true
  end

  # Move towards a unit
  def move_to_unit(unit, offset_x = 0, offset_y = 0)
    move_to_position(unit.position.x + offset_x, y = unit.position.y + offset_y)
  end

  # Move towards a unit by id
  def move_to_unit_by_id(unit_id, offset_x = 0, offset_y = 0)
    unit = @battlefield.select_unit_by_id(unit_id)
    move_to_unit(unit, offset_x, offset_y)
  end

  # Move back under tower
  def fallback_under_tower
    @current_strategy = :fallback
    tower, = select_unit_by_distance(@battlefield.us, :tower, :nearest)
    move_to_unit(tower)
  end

  # Move to frontline
  def move_to_frontline
    @current_strategy = :frontline
    tower, = select_unit_by_distance(@battlefield.us, :tower, :nearest)
    unit, = tower.select_unit_by_distance(@battlefield.us, :unit, :farthest)
    move_to_unit(unit, -1)
  end

  # Move to backline
  def move_to_backline
    @current_strategy = :backline
    tower, = select_unit_by_distance(@battlefield.us, :tower, :nearest)
    unit, = tower.select_unit_by_distance(@battlefield.us, :unit, :nearest)
    move_to_unit(unit, -1)
  end

  # Check if the hero is protected by minions
  def behind_minions?
    tower, = select_unit_by_distance(@battlefield.them, :tower, :farthest)
    front_minion, = tower.select_unit_by_distance(@battlefield.us, :unit, :nearest)

    tower.distance_to_unit(front_minion) < tower.distance_to_unit(self)
  end

  ##############################################################################

  def buy(item)
    @items << item
    puts "BUY #{item.name}"
  end

  def buy_by_price(items, priority, price, gold)
    if price == :cheapest
      items.sort_by!(&:cost)
      buy(items.first)
    else
      items.sort_by! { |item| item.instance_variable_get('@' + priority.to_s) }.reverse
      items.each do |item|
        next if item.cost > gold
        buy(item)
        break
      end
    end
  end
end

################################################################################
## Strategies
################################################################################

# Class extension for possible strategies
class Battlefield
  # Play the round according to strategy
  def play_round
    hero = us.heroes[0]
    keep_distance_and_attack(hero)
  end

  def keep_distance_and_attack(hero)
    our_tower = us.towers[0]
    closest_unit, closest_distance = our_tower.select_unit_by_distance(them, :any, :nearest, :with_range)
    _, closest_target_distance = closest_unit.select_unit_by_distance(us, :unit, :nearest)

    move_offset = closest_target_distance > closest_unit.attack_range ? closest_unit.movement_speed : 1

    path = (closest_unit.position - our_tower.position).norm
    destination = our_tower.position + (path * (closest_distance - move_offset))
    nearest_unit, = hero.select_unit_by_distance(them, :any, :nearest)

    hero.move_attack(destination, nearest_unit) # unless buy(hero, :damage, :cheapest)
  end

  def buy(hero, priority, price)
    items = create_item_list_for_buying(priority)
    items.sort_by!(&:cost)

    return false if price == :cheapest && items.first.cost > us.gold ||
                    price == :best && items.last.cost > us.gold ||
                    hero.items.count == 4

    hero.buy_by_price(items, priority, price, us.gold)
  end

  def create_item_list_for_buying(priority)
    items = []
    shop.each do |item|
      next if item.instance_variable_get('@' + priority.to_s).zero?
      items << item
    end
    items
  end
end

################################################################################
## Initial Data
################################################################################
@us = Team.new(gets.to_i)
@them = Team.new((@us.side - 1).abs)
@battlefield = Battlefield.new(@us, @them)

bush_and_spawn_point_count = gets.to_i
bush_and_spawn_point_count.times do
  @battlefield.add_entities(gets.split(' '))
end

@item_count = gets.to_i
@item_count.times do
  @battlefield.provision_shop_with_items(gets.split(' '))

end

################################################################################
## Game Logic
################################################################################

# Check if it's the initialization round
def initialization_round?
  gets.to_i < 0
end

################################################################################
## Game Loop
################################################################################

loop do
  @battlefield.count_gold

  is_initialization_round = initialization_round?

  @battlefield.populate

  if is_initialization_round
    @battlefield.select_hero
  else
    @battlefield.play_round
  end

  @battlefield.prepare_for_new_round
end
