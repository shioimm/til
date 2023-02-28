def foo
  raise LightningTalkTimeout if rand(30) > 15
rescue
  p "OMG"
else
  p "Yaaaaaay"
ensure
  p "Anyway, #ruby30th"
end

foo
