# seedファイルで画像データを格納する際、対象の画像ファイルがSVGだと表示されない
## 挙動
- 元々あったseedデータを参考にして新しいseedデータを作成したところ、ファイルが正常に展開されなかった

```ruby
# 元々あったseedデータ
# db/fixtures/foo.rb

Foo.seed do |s|
  s.id = 2
  s.name = 'hogehoge'
  s.image = StringIO.new(File.binread(Rails.root.join('db/fixtures/images/foos/hogehoge.png')))
end
```

```ruby
# 新しく追加したデータ
# db/fixtures/bar.rb

Bar.seed do |s|
  s.id = 2
  s.name = 'fugafuga'
  s.image = StringIO.new(File.binread(Rails.root.join('db/fixtures/images/bars/hogehoge.svg')))
end
```
- ファイルパスを確認したところ、指定しているファイルに拡張子が存在しなかった

## 原因
- SVGはバイナリファイルではなくテキストで構成されているため、`File.binread`によって読み込むことができない

## 対策
- ファイルをテキストとして読み込むようにする
```ruby
# db/fixtures/bar.rb

Bar.seed do |s|
  s.id = 2
  s.name = 'fugafuga'
  s.image = StringIO.new(File.read(Rails.root.join('db/fixtures/images/bars/hogehoge.svg')))
end
```

- また、`StringIO`を使わず直接`File`クラスから`IO`オブジェクトを返すように変更した

```ruby
# db/fixtures/bar.rb

Bar.seed do |s|
  s.id = 2
  s.name = 'fugafuga'
  s.image = File.open(Rails.root.join('db/fixtures/images/bars/hogehoge.svg'))
end
```
