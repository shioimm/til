def ractor
  r = Ractor.new 'ok' do |msg|
    msg
  end

  r.take
end

pid = fork { p ractor }

Process.waitpid(pid)
