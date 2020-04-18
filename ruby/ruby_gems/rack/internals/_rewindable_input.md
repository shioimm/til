# Rack::RewindableInput
- 引用: [rack/lib/rack/rewindable_input.rb](https://github.com/rack/rack/blob/master/lib/rack/rewindable_input.rb)
- 引用: [rack/README.rdoc](https://github.com/rack/rack/blob/master/README.rdoc)
- 翻訳参考: [DeepL](https://www.deepl.com/translator)

## 概要
- テンポラリファイルバッファを使用して任意のIOオブジェクトを巻き戻し可能にするヘルパー
- データをtempfileにバッファリングすることにより任意のIOオブジェクトを巻き戻し可能にする
- 入力ストリームのIOが本来巻き戻し不可能なもの(パイプやソケットなど)であっても
  このクラスのオブジェクトでラップすること巻き戻し可能にすることができる
- 終了時に#closeを呼び、RewindableInputが使用する一時的なリソースを解放する
  - #closeを呼んでも元のIO オブジェクトが閉じるわけではない
