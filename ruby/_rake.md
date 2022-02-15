# Rake
## Rakefile
#### タスクの定義
```ruby
task :<task name> , [<arg>, ... ] => [:<prereq>, ... ] do |<arg>|
  <action>
end
```

#### ファイルがない場合のみ実行するタスクの定義
```ruby
file "<file name>" do
  <action>
  open("/path/to/<file name>", "w") { |f| f << <action> }
end
```
