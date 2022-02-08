# mruby/c
- 小型・省電力デバイス向けのmruby実装
- 従来のmrubyを更に軽量化

## 特徴
- mrubyとバイトコードは互換
- 省メモリ
  - 従来のmruby比で10分の1程度(メモリ消費50KB未満(RAM)で稼働)
- コンカレントな動作
  - OSを使用せず複数のRubyプログラムを同時に動かすことが可能

# mrubyとmruby/cの違い
- Rubyの機能
  - mruby -> Rubyのほぼ全ての機能をサポート・多くのgem
  - mruby/c -> Rubyの最小の機能のみをサポート
- 実効性能
  - mruby -> 実効性能が高い
  - mruby/c -> 少ないメモリで動作する
- OSの利用
  - mruby -> OSありを想定
  - mruby/c -> OSなしを想定

## 参照・引用:
- [mruby／c](https://www.s-itoc.jp/activity/research/mrubyc/)
