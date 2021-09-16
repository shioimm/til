# 参照: dRubyによる分散・Webプログラミング
require 'drb/drb'

class ReminderCUI
  def initialize(reminder)
    @model = reminder
  end

  def list
    @model.to_a.each do |k, v|
      puts format_item(k, v)
    end
    nil
  end

  def add(str)
    @model.add str
  end

  def show(key)
    puts format_item key, @model[key]
  end

  def delete(key)
    puts " [delete?(Y/n)]: #{@model[key]}"

    if gets.chomp != 'Y'
      puts 'canceled'
      return
    end

    @model.delete(key)
    list
  end

  private

    def format_item(key, str)
      sprintf("%3d: %s\n", key, str)
    end
end

# $ irb --prompt simple -r ./practices/druby/druby_book/reminder_cui0.rb -r drb/drb
# >> there = DRbObject.new_with_uri('druby://localhost:12345')
# >> r = ReminderCUI.new(there)
