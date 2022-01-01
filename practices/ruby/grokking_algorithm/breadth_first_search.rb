def search(graph)
  queue = graph.keys
  checked = []

  until queue.empty?
    queue.flatten!
    person = queue.pop

    if !checked.include?(person) && person.chars.last == 'm'
      p "#{person} is a mango seller!"
      return true
    else
      queue.push graph[person]
      checked << person
    end
  end

  false
end

graph = {
  'you'    => ['alice', 'bob', 'claire'],
  'alice'  => ['peggy'],
  'bob'    => ['anuj', 'peggy'],
  'claire' => ['thom', 'jonny'],
  'peggy'  => [],
  'anuj'   => [],
  'thom'   => [],
  'jonny'  => []
}

p search(graph)
