# XSS
- クロスサイトスクリプティング
- 多くの攻撃の起点となる
- ユーザー入力コンテンツなどに有害なJavaScriptを書き込み、閲覧したユーザーに被害を与える

#### 発生箇所
- HTML・JavaScriptを生成している箇所

#### 影響範囲
- アプリケーション全体

#### 影響の種類
- ユーザーのプラウザ上でJavaScriptが実行される

#### 原因
- メタ文字をエスケープしていない

#### 対策
- 属性値・メタ文字をエスケープする
- Cookieに`httpOnly`属性を付与する(JavaScriptからアクセスできなくなる)
- Content-Security-Policyを利用してWebサイトで使用する機能をサーバーから設定する
  - 想定外のJavaScriptが実行されることを防ぐ
  - Content-Security-PolicyはレスポンスヘッダもしくはHTMLのメタタグへ埋め込むことができる

## 参照
- 安全なWebアプリケーションの作り方(脆弱性が生まれる原理と対策の実践)
- Real World HTTP 第2版