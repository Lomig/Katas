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
