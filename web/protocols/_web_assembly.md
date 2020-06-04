# WebAssembly
- 参照: [WebAssembly](https://developer.mozilla.org/ja/docs/WebAssembly)
- 参照: [WebAssembly: 「なぜ」と「どうやって」 翻訳記事](https://dev.to/nabbisen/webassembly--3385)
- 参照: [3分でわかる WebAssembly](https://active.nikkeibp.co.jp/atcl/act/19/00146/032000001/)

## 概要
- モダンなWebブラウザで実行でき、ネイティブコードに近いパフォーマンスで動作する
  バイナリ形式のコンパクトで低レベルなアセンブリ風言語
- C/C++やRustプログラムをコンパイルし、Web上で実行することができる
- JavaScriptと並行して動作する
  - 高速化したい部分をWebAssemblyで記述してJavaScriptから呼び出したり、
    WebAssemblyバイトコード(WASMコード)からJavaScriptを呼び出したりできる

## 利点
- スピード
- 移植性
- 柔軟性

## Webアプリケーションの高速化
1. アプリケーションプログラムをLLVMベースのコンパイラ基盤でコンパイル
2. WASMコードを生成
   WASMコードはバイナリコード形式によって記述される
3. 生成したWASMコードをWebアプリケーションとしてアップロードし実行
