fib = Fiber.new {
  loop do
    now = Time.now.strftime('%Y/%m/%d %H:%M:%S')

    Fiber.yield now

    sleep 1
  end
}

10.times { puts fib.resume }
