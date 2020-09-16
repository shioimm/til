def binary_search(list, item)
  row = 0
  high = list.length - 1
  count = 1

  while row <= high
    middle = (row + high) / 2
    guess = list[middle]

    if guess == item
      return "Found #{item}."
    elsif guess > item
      high = middle - 1
      count += 1
    elsif guess < item
      row = middle + 1
      count += 1
    end
  end

  'Not found.'
end

p binary_search([1, 2, 3], 2)
