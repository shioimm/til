# WebAssembly (WASM) / WASI
#### WebAssembly (WASM)
- Webブラウザで高速、安全に実行で可能なバイナリソフトウェア形式
- 高級言語で開発したプログラムをコンパイルすることでバイナリを生成できる
- 元々Webブラウザ上で高速、安全に実行可能なバイナリフォーマットとして開発されたが
  その後Webブラウザだけでなく各OSやCDNエッジなどにもWebAssemblyを実行可能なランタイムが開発された

#### WASI (WebAssembly System Interface)
- WebAssemblyをブラウザを介さずクロスプラットフォームで実行できるようにするためのインターフェース仕様
- WASMアプリケーションに対してOSのシステムコールを抽象化することでOS依存をなくし、
  ポータブルなWASMアプリケーションを実現する
- WASIに従って開発されたWebAssemblyアプリケーションはいずれのWASIに対応したWebAssemblyランタイムで実行可能

#### アセンブリ言語との違い
- アセンブリ言語は各プロセッサ・アーキテクチャごとに対応する
- WASMは特定のプロセッサ・アーキテクチャではなくWASIに対応する

## WebアプリケーションとしてのWASMコード実行
1. 高級言語でソースプログラムを記述する
2. ソースプログラムをコンパイルし、WebAssemblyバイトコード (WASMコード) を生成する
   - C/C++ -> LLVMベースのコンパイラ基盤やEmscriptenなどをコンパイルに使用する
   - Rust -> rustcをコンパイルに使用する
3. WebアプリケーションにWASMコードをロードする
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
