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
