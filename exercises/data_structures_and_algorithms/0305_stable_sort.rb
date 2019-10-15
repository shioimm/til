require_relative '0303_bubble_sort'
require_relative '0304_selection_sort'

def stable?(sorted, arr)
  if bubble_sort(arr).map(&:object_id) == sorted.map(&:object_id)
    'Stable'
  else
    'Not Stable'
  end
end

arr = %w[f a b e c a d e]

p stable?(selection_sort(arr), arr)
