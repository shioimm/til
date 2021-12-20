# CSP (Content Securiity Policy)
- Webサイトの運用者によってブラウザの挙動を制御できるようにする宣言的なセキュリティの仕組み
  - 対象のWebページでContent-Security-Policyヘッダ・ポリシーを返すように設定することにより、
    信頼できないサードパーティーからのスクリプトの利用をブラウザに無視させたり、
    混在コンテンツをブロックしたりすることができる
  - XSSやデータインジェクション攻撃などのような特定の種類の攻撃を検知し、影響を軽減する

```
Content-Security-Policy: default-src 'self'; img-src *;
                           object-src *.cdn.example.com;
                           script-src scripts.example.com
```

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
