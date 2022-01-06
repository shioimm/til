# WebAssembly
- Webブラウザなどで実行が可能なバイナリ形式のアセンブリ風言語
  - スピード
  - 移植性
  - 柔軟性

#### アセンブリ風言語
- アセンブリ言語は各プロセッサ・アーキテクチャごとに対応する
- WASMは特定のプロセッサ・アーキテクチャではなくブラウザ (あるいはWASMを解釈する機構) に対応する

## WebアプリケーションとしてのWASMコード実行
1. C/C++、Rust、TypeScriptなどでアプリケーションプログラムを記述する
2. アプリケーションプログラムをLLVMベースのコンパイラ基盤でコンパイルし、
   WebAssemblyバイトコード (WASMコード) を生成する
   - C/C++ -> Emscripten
   - Rust -> rustc
3. WASMコードをWebアプリケーションにロードする
4. WebブラウザがWASMを解釈し実行する
    - JSと並行して動作する
    - JSからWASMを呼び出したりWASMからJSを呼び出すこともできる

## 参照
- [WebAssembly: 「なぜ」と「どうやって」 翻訳記事](https://dev.to/nabbisen/webassembly--3385)
- [3分でわかる WebAssembly](https://active.nikkeibp.co.jp/atcl/act/19/00146/032000001/)
- [JavaScriptエンジン「V8 release v6.5」リリース。WebAssemblyバイナリをダウンロードと並行してコンパイル、ダウンロード完了とほぼ同時にコンパイルも完了](https://www.publickey1.jp/blog/18/javascriptv8_release_v65webassembly.html)
