connectables = [1, 2, 3, 4, 5]
connectings = [6]
connected = nil
state = :v46w

connected = loop do
  p state
  case state
  when :v46c
    connectables.push connectings.shift
    state = :v46w
    next
  when :v46w
    while (connectable = connectables.shift)
      puts "connectable: #{connectable}"
      if connectable > 6
        connected = connectable
        state = :success
        break
      else
        next if connectables.any?

        if connectings.any?
          state = :v46c
        else
          state = :failure
        end
      end
    end
  when :success
    break connected
  when :failure
    break 'failed'
  end
end

p connected
