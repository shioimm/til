# WebAssembly
- WebAssemblyランタイム上で実行可能なバイナリ、アセンブリ風言語
- Webブラウザ上で実行可能なバイナリフォーマットとして開発され、
  その後Webブラウザから切り離されてOS上で実行可能なランタイムが開発された
  - スピード
  - 移植性
  - 柔軟性

#### アセンブリ風言語
- アセンブリ言語は各プロセッサ・アーキテクチャごとに対応する
- WASMは特定のプロセッサ・アーキテクチャではなくWASIに対応する

#### WASI (WebAssembly System Interface)
- WASMアプリケーションに対してOSのシステムコールを抽象化することでOS依存をなくし、
  ポータブルなWASMアプリケーションを実現する業界標準仕様のAPI

## WebアプリケーションとしてのWASMコード実行
1. C/C++、Rust、TypeScriptなどでソースプログラムを記述する
2. ソースプログラムをLLVMベースのコンパイラ基盤 (LLVMからJavaScriptへのコンパイラ) でコンパイルし、
   WebAssemblyバイトコード (WASMコード) を生成する
   - C/C++ -> Emscripten (emcc: Emscriptenコンパイラのフロントエンド)
   - Rust -> rustc
3. WASMコードをWebアプリケーションにロードする
4. WebブラウザがWASMを解釈し実行する
    - JSと並行して動作する
    - JSからWASMを呼び出したりWASMからJSを呼び出すこともできる

## Binaryen
- [Binaryen](https://github.com/WebAssembly/binaryen)
- WASM向けのコンパイラ/ツールチェインインフラストラクチャ
- LLVMによる出力をWASMにコンパイルする

## 参照
- [WebAssembly: 「なぜ」と「どうやって」 翻訳記事](https://dev.to/nabbisen/webassembly--3385)
- [3分でわかる WebAssembly](https://active.nikkeibp.co.jp/atcl/act/19/00146/032000001/)
- [JavaScriptエンジン「V8 release v6.5」リリース。WebAssemblyバイナリをダウンロードと並行してコンパイル、ダウンロード完了とほぼ同時にコンパイルも完了](https://www.publickey1.jp/blog/18/javascriptv8_release_v65webassembly.html)
- [RubyがWebAssemblyのWASI対応へ前進。ブラウザでもサーバでもエッジでもどこでもWebAssembly版Rubyが動くように](https://www.publickey1.jp/blog/22/rubywebassemblywasiwebassemblyruby.html)
