# Propshaft
- Sprocketsに替わるアセットパイプラインライブラリ
- シンプルかつ高速

#### 背景
- 元々はHTTPコネクション数を節約するためSprocketsを用いてアセットのバンドルやminifyを行なっていた
- HTTP/2普及により、コネクションを節約する必要性がなくなった

## Propshaftが提供するもの
- Configurable load path
  - アプリケーション内の複数の場所からディレクトリを登録し、
    それらを単一の参照点としてアセットを参照することができる
- Digest stamping
  - すべてのアセットにダイジェストハッシュをスタンプ
- Development server
- Basic compilers
  - 単純な入力->出力コンパイラの設定を提供
  - デフォルトではCSSの`asset-path`関数呼び出しを`url(digested-asset)`に変換するために使用

## 参照
- [Propshaft](https://github.com/rails/propshaft)
