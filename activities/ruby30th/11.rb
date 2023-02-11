# WIP
def foo
  raise
rescue => e
  p e
else
  # unreached
ensure
  p "Anyway, #ruby30th"
end
