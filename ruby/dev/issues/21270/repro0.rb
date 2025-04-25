require_relative "./repro"

Fiber.set_scheduler(Scheduler.new)

puts "#{Fiber.current.object_id}: Main fiber"

Fiber.schedule do
  puts "#{Fiber.current.object_id}: Creating socket"

  socket = Socket.new(:AF_INET6, :SOCK_STREAM, 0)
  sockaddr = Socket.sockaddr_in(12345, "example.com")
  socket.connect_nonblock(sockaddr)

  puts "#{Fiber.current.object_id}: Connected"
end

Fiber.schedule do
  puts "#{Fiber.current.object_id}: Sleeping"
  sleep 2
  puts "#{Fiber.current.object_id}: Done sleeping"
end

puts "#{Fiber.current.object_id}: Both fibers started"
