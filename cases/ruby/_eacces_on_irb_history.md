# `Permission denied @ rb_sysopen - /Users/misakishioi/.irb_history (Errno::EACCES)`
- 別ユーザーでログインしてirbを開こうとした際に発生
```
$ sudo -u misakishioi2 irb -r drb
Password:
/Users/misakishioi/.rbenv/versions/3.0.1/lib/ruby/3.0.0/irb/ext/save-history.rb:73:in `initialize': Permission denied @ rb_sysopen - /Users/misakishioi/.irb_history (Errno::EACCES)
```

- .irb-historyの置き場所を`ENV['HOME']`以下に設定すると開けるようになる
```
require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 10000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-history"
```

- [Rails console Permission denied @ `rb_sysopen Error`](https://stackoverflow.com/questions/52360624/rails-console-permission-denied-rb-sysopen-error)
