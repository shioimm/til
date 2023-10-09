graph = {
    'start' => {
    'a' => 6,
    'b' => 2
  },
  'a' => {
    'fin' => 1
  },
  'b' => {
    'a' => 3,
    'fin' => 5
  },
  'fin' => nil
}

costs = {
  'a' => 6,
  'b' => 2,
  'fin' => Float::INFINITY
}

parents = {
  'a' => 'start',
  'b' => 'start',
  'fin' => nil
}

processed = []

def find_lowest_cost_node(costs, processed)
  lowest_cost = Float::INFINITY
  lowest_cost_node = nil

  costs.each do |node, cost|
    if !processed.include?(node) && cost < lowest_cost
      lowest_cost = cost
      lowest_cost_node = node
    end
  end

  lowest_cost_node == 'fin' ? nil : lowest_cost_node
end

node = find_lowest_cost_node(costs, processed)
p 'start ↓'
while node
  cost = costs[node]
  neighbors = graph[node]
  neighbors.keys.each do |n|
    new_cost = cost + neighbors[n]
    if costs[n] > new_cost
      costs[n] = new_cost
      parents[n] = node
      processed << node
    end
  end
  p "#{node} ↓"
  node = find_lowest_cost_node(costs, processed)
end
p 'fin'
