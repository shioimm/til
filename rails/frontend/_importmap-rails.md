# importmap-rails
- トランスパイルやバンドルなしでESモジュールをブラウザで直接インポートするためのライブラリ
  - Webpack、Yarn、npm、その他のJSツールチェインは必要なく、Railsのアセットパイプラインを使用する
- バージョン管理下のファイルやダイジェストされたファイルに対応する論理名を用いて解決を行う
- 1個の巨大なJavaScriptファイルを送信するのではなく、小さなJavaScriptファイルを多数送信する (HTTP/2の利用)
- es-module-shmisを同梱

## 参照
- [importmap-rails](https://github.com/rails/importmap-rails)
- [Rails 7: import-map-rails gem README（翻訳）](https://techracho.bpsinc.jp/hachi8833/2021_10_07/112183)
