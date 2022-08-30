# CSP (Content Security Policy)
- Content-Security-Policyレスポンスヘッダを返すことによりクライアントのブラウザの挙動を制御できるよう仕組み
  - 信頼できないサードパーティーからのスクリプトの利用をブラウザに無視させたり、
    混在コンテンツをブロックするために有用
  - XSSなどブラウザを利用する攻撃の影響を軽減する

```
Content-Security-Policy: default-src 'self'; img-src *;
                         object-src *.cdn.example.com;
                         script-src scripts.example.com
```

#### `script-src 'unsafe-inline'`
- イベントハンドラを含むすべてのインラインスクリプトの実行を許可 (危険)

#### `script-src 'unsafe-eval'`
- `eval()`や`Function()`等の文字列をコードとして評価するようなメソッドの実行をブロック (やや危険)

#### `script-src 'self'`
- 同じオリジンから読み込まれたスクリプトのみ実行を許可 (デフォルト)

#### `script-src 'nonce-*****'`
- レスポンスヘッダで返されたnonceと同じnonceが設定されたスクリプトのみ読み込み・実行を許可

#### `script-src 'nonce-*****' 'strict-dynamic'`
- レスポンスヘッダで返されたnonceと同じnonceが設定されたスクリプトのみ読み込み・実行を許可
- 実行を許可したスクリプトから読み込まれたスクリプトも同様に実行を許可

## レポート
- Content-Security-Policyヘッダにreport-uri命令を付けることでレポート機能を付加する
- CSPのポリシー違反が発生した際、レポートが指定したURIへPOSTで送信されるようになる

```
{
  "csp-report": {
    "document-uri": "http://example.org/page.html",
    "referrer": "http://evil.example.com/haxor.html",
    "blocked-uri": "http://evil.example.com/image.png",
    "violated-directive": "default-src 'self'",
    "original-policy": "default-src 'self'; report-uri http://example.org/csp-report.cgi"
  }
}
```

## 参照
- [コンテンツセキュリティポリシー (CSP)](https://developer.mozilla.org/ja/docs/Web/HTTP/CSP)
- プロフェッショナルSSL/TLS
