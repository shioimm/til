# https://exercism.org/tracks/ruby/exercises/dnd-character

module DiceRoller
  def self.roll!
    rand(1..6)
  end

  def self.roll_four!
    4.times.map { roll! }
  end
end

class DndCharacter
  ATTRIBUTES = %i[strength dexterity constitution intelligence wisdom charisma]
  BASE_HITPOINTS = 10

  attr_reader *ATTRIBUTES, :hitpoints

  def self.modifier(constitution)
    (constitution - BASE_HITPOINTS) / 2
  end

  def initialize
    ATTRIBUTES.each do |att|
      self.instance_variable_set("@#{att}", calcurate_value)
    end

    @hitpoints = BASE_HITPOINTS + self.class.modifier(@constitution)
  end

  private

  def calcurate_value
    rolls = DiceRoller.roll_four!
    rolls.max(3).sum
  end
end
