# mruby
- 参照: [mruby/mruby](https://github.com/mruby/mruby)
- 参照: [オープンソースの言語／mrubyとは](https://www.ossnews.jp/oss_info/mruby)

## TL;DR
- 組み込みシステム向けの軽量なRuby言語処理系
- モジュール化されており、他のアプリケーション内にリンクして組み込むことが可能な設計となっている

## 特徴
- Rubyベース
- コンパイラ言語
  - mruby VM上で動作し、環境に依存しない
  - 実行形式の自由度が高い
    - バイトコードに変換しての実行
    - mrubyスクリプトのままの実行
- C言語-mruby間での相互互換性・モジュラビリティ
- インクリメンタルガベージコレクション
- 省メモリ

## 提供ツール
- mruby -> インタプリタプログラム
- mirb -> 対話型mrubyシェル
- mrbc -> mrubyコンパイラ

## 関連プロジェクト
- [Related Projects](https://github.com/mruby/mruby/wiki/Related-Projects)

# mruby/c
- 参照・引用: [mruby／c](https://www.s-itoc.jp/activity/research/mrubyc/)

## TL;DR
- 小型端末向けの開発言語
- 従来のmrubyより更にメモリ消費量を削減したmruby実装

## 特徴
- 高い開発生産性
  - C言語と比較して5倍程度の開発生産性を想定
- 省メモリ
  - 従来のmruby比で10分の1程度(メモリ消費50KB未満(RAM)で稼働)
- コンカレントな動作
  - OSを使用せず複数のRubyプログラムを同時に動かすことが可能
