## Tips

#### Rubyで外部コマンド実行
- 実行したいコマンドを\`\`で囲う
```ruby
`open index.html`
```
- 返り値を変数に代入することも可能
```ruby
ls = `ls -la`
p ls
```
