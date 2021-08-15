# WebAssembly
- Webブラウザ上で高速実行が可能なバイナリフォーマット
  - スピード
  - 移植性
  - 柔軟性
- プログラムはブラウザにダウンロードされた後(あるいはダウンロード中 = Streaming Compilation)
  ネイティブコードにコンパイルされ、実行される
- JavaScriptと並行して動作する
  - 高速化したい部分をWebAssemblyで記述してJavaScriptから呼び出したり、
    WebAssemblyバイトコード(WASMコード)からJavaScriptを呼び出したりできる

## Webアプリケーションの高速化
1. アプリケーションプログラムをLLVMベースのコンパイラ基盤でコンパイル
2. WASMコードを生成
   WASMコードはバイナリコード形式によって記述される
3. 生成したWASMコードをWebアプリケーションとしてアップロードし実行

## 参照
- [WebAssembly](https://developer.mozilla.org/ja/docs/WebAssembly)
- [WebAssembly: 「なぜ」と「どうやって」 翻訳記事](https://dev.to/nabbisen/webassembly--3385)
- [3分でわかる WebAssembly](https://active.nikkeibp.co.jp/atcl/act/19/00146/032000001/)
- [JavaScriptエンジン「V8 release v6.5」リリース。WebAssemblyバイナリをダウンロードと並行してコンパイル、ダウンロード完了とほぼ同時にコンパイルも完了](https://www.publickey1.jp/blog/18/javascriptv8_release_v65webassembly.html)
