# Rack::Directory
- 引用: [rack/lib/rack/directory.rb](https://github.com/rack/rack/blob/master/lib/rack/directory.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)

## 概要
- 指定されたディレクトリ以下のファイルについて、ディレクトリインデックスと共に提供するヘルパー
- Rackリクエストのパス情報に応じて、与えられた+root+以下のエントリを提供する
  - ディレクトリが見つかった場合、ファイルの内容がhtmlベースのインデックスで表示される
  - ファイルが見つかった場合、環境変数は指定された+app+に渡される
  - +app+が指定されていない場合、同じ+root+のRack::Filesが使用される

## `Rack::Directory#call`
```ruby
    def call(env)
      # strip body if this is a HEAD call
      @head.call env
    end
```
