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
