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
