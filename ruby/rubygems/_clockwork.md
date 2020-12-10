# clockwork
- [clockwork](https://github.com/adamwiggins/clockwork)
- cronの代替えとして定期実行できる

### clockworkをrakeタスクとして実行したい
- 参照: [How do I use Rails clockwork gem to run rake tasks?](https://stackoverflow.com/questions/11513058/how-do-i-use-rails-clockwork-gem-to-run-rake-tasks)
```ruby
# config/clock.rb

require_relative 'boot'
require_relative 'environment' # 実行環境を読み込む
require 'clockwork'

def execute_rake(file, task)
  require 'rake'
  rake = Rake::Application.new
  Rake.application = rake
  Rake::Task.define_task(:environment)
  load "#{Rails.root}/lib/tasks/#{file}" # タスクを読み込む
  rake[task].invoke
end

module Clockwork
  every(1.day, 'remind', at: '18:00') do
    # 第一引数にファイル名、第二引数にnamespace:task名
    execute_rake 'remind.rake', 'remind:task'
  end
end
```

```
// Procfile

clock: bundle exec clockwork config/clock.rb
```


### Herokuで実行したい
- タイムゾーンを設定する
```
heroku config:set TZ=Asia/Tokyo -a sushi
```
- 新しいプロセスを設定
```
// プロセスを確認
❯❯❯ heroku ps --app sushi

// clockを起動
❯❯❯ heroku ps:scale clock=1 --app sushi

// clockを停止する場合
❯❯❯ heroku ps:scale clock=0 --app sushi
```
