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
