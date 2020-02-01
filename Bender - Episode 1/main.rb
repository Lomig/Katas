################################################################################
## Classes
################################################################################

## This class is used to represent the map Bender wanders in
#### It handles the position of the robot as well as the event markers
class Map
  attr_reader :number_rows, :number_columns, :current_position

  def initialize(row, column)
    @number_rows = row
    @number_columns = column

    @map = Array.new(row) { Array.new(column) }
    @current_position = []
    @next_position = []

    populate
  end

  def populate
    starting_position_column = nil
    starting_position_row = nil

    teleport1_position_column = nil
    teleport1_position_row = nil

    teleport2_position_column = nil
    teleport2_position_row = nil

    @number_rows.times do |i|
      @map[i] = gets.chomp.chars
      unless starting_position_column
        starting_position_column = @map[i].find_index('@')
        starting_position_row = i
      end

      unless teleport1_position_column
        teleport1_position_column = @map[i].find_index('T')
        teleport1_position_row = i
        @map[i][teleport1_position_column] = 'Z' if teleport1_position_column

      end

      if teleport1_position_column && !teleport2_position_column
        teleport2_position_column = @map[i].find_index('T')
        teleport2_position_row = i
      end
    end

    @current_position = [starting_position_row, starting_position_column]
    @teleporter = [
      [teleport1_position_row, teleport1_position_column],
      [teleport2_position_row, teleport2_position_column]
    ]
  end

  def look(direction)
    @next_position =
      case direction
      when :north
        [@current_position[0] - 1, @current_position[1]]
      when :south
        [@current_position[0] + 1, @current_position[1]]
      when :west
        [@current_position[0], @current_position[1] - 1]
      else #:east
        [@current_position[0], @current_position[1] + 1]
      end
  end

  def analyze_next_position
    @map[@next_position[0]][@next_position[1]]
  end

  def move(direction)
    @current_position =
      case direction
      when :north
        [@current_position[0] - 1, @current_position[1]]
      when :south
        [@current_position[0] + 1, @current_position[1]]
      when :west
        [@current_position[0], @current_position[1] - 1]
      else #:east
        [@current_position[0], @current_position[1] + 1]
      end
  end

  def teleport
    @current_position =
      @current_position == @teleporter[0] ? @teleporter[1] : @teleporter[0]
  end

  def breaking_time
    @map[@current_position[0]][@current_position[1]] = ' '
  end
end

## This class handles the Robot Logic
#### The "drive" to move will be handled in an external Game Loop
#### Bender possesses a map
#### Bender has states
#### Bender has directions
#### Bender keeps track of the movements he does
class Robot
  attr_reader :is_dead, :movement_prediction

  def initialize(map)
    @map = map

    @direction_priority = %i[south east north west]

    @current_direction = :south
    @is_in_breaker_mode = false
    @is_dead = false

    @broken_walls = 0

    @movement_prediction = []
    @state_list = []
  end

  def inverse_priority
    @direction_priority.reverse!
  end

  def toggle_breaker_mode
    @is_in_breaker_mode = !@is_in_breaker_mode
  end

  def routine
    @map.look(@current_direction)
    next_event = @map.analyze_next_position

    change_state(next_event)
  end

  def change_state(event)
    case event
    when '$'
      finalize_movement
      destroy_robot
    when '#'
      change_direction
    when 'S'
      finalize_movement
      @current_direction = :south
    when 'E'
      finalize_movement
      @current_direction = :east
    when 'N'
      finalize_movement
      @current_direction = :north
    when 'W'
      finalize_movement
      @current_direction = :west
    when 'I'
      finalize_movement
      inverse_priority
    when 'B'
      finalize_movement
      toggle_breaker_mode
    when 'T', 'Z'
      finalize_movement
      @map.teleport
    when 'X'
      breaker_mode_opportunity
    else
      finalize_movement
    end
  end

  def change_direction
    @direction_priority.each do |direction|
      @map.look(direction)
      next_event = @map.analyze_next_position
      next if next_event == '#' || (next_event == 'X' && !@is_in_breaker_mode)
      @current_direction = direction
      break
    end
  end

  def breaker_mode_opportunity
    if @is_in_breaker_mode
      finalize_movement
      @map.breaking_time
      @broken_walls += 1
    else
      change_direction
    end
  end

  def finalize_movement
    @movement_prediction << @current_direction
    @map.move(@current_direction)

    check_loop
  end

  def check_loop
    current_state = [
      @map.current_position,
      @direction_priority,
      @current_direction,
      @is_in_breaker_mode,
      @broken_walls
    ]

    if @state_list.include?(current_state)
      @movement_prediction = ['LOOP']
      destroy_robot
    else
      @state_list << current_state
    end
  end

  def destroy_robot
    @is_dead = true
  end
end

################################################################################
## Initialization
################################################################################

row, column = gets.split(' ').map(&:to_i)

town = Map.new(row, column)
bender = Robot.new(town)

################################################################################
## Game Loop
################################################################################

bender.routine until bender.is_dead

bender.movement_prediction.each do |move|
  puts move.to_s.upcase
end
