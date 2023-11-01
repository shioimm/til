# Rubyスクリプトから外部コマンド実行
#### Kernel#\`
- 実行したいコマンドを\`\`で囲う

```ruby
`open index.html`
```

- 返り値を変数に代入することも可能

```ruby
ls = `ls -la`
p ls
```

#### Kernel#system
- 実行したいコードを引数に渡す

```ruby
system('ls')
system('ls', '--help')
```

- Kernel#\`との違いは返り値
  - systemは終了コードが0の場合true、それ以外の場合falseを返す
