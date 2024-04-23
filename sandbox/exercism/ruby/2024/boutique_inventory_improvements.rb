# https://exercism.org/tracks/ruby/exercises/boutique-inventory-improvements

class BoutiqueInventory
  attr_reader :items

  # The instructions suggest using OpenStruct, but this has been deprecated in Ruby 3.0 and later.
  # https://github.com/ruby/ostruct/blob/69f6661f6219175adc8949ff61ff10b558bc8494/lib/ostruct.rb#L67-L107
  # Additionally, Data class introduced in Ruby 3.2 is sufficient for solving this problem.
  Item = Data.define(:price, :name, :quantity_by_size)

  def initialize(items)
    @items = items.map { |item| Item.new(**item) }
  end

  def item_names
    items.map(&:name).sort
  end

  def total_stock
    items.map(&:quantity_by_size).flat_map(&:values).sum
  end
end
