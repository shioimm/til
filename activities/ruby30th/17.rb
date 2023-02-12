pid = fork do
  exec "echo", "-n", "#ruby"
end
Process.waitpid(pid)
system("echo 30th")
