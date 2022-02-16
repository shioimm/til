# Rake
## Rakefile
```ruby
task :<task name> , [<arg>, ... ] => [:<prereq>, ... ] do |<arg>|
  <action>
end

# ファイルタスク
file "<file name>" do
  <action>
  open("/path/to/<file name>", "w") { |f| f << <action> }
end

# 依存関係の解決
# taskの実行に"file.file"が必要
task :<task name> => "file name"

# "file name"がない場合、"_file1 name", "_file2 name"を元に"file name"を生成
file "file name" => ["_file1 name", "_file2 name"] do |<arg>|
  <action>
  open("/path/to/<file name>", "w") { |f| f << <action> }
end
```
