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
