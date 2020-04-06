# CHANGELOG 2.0.0.rc -> 2.3.0
- 引用: [CHANGELOG](https://github.com/rack/rack/blob/master/CHANGELOG.md)

## 2016
### 06-30
#### 2.0.1
[Changed]
- JSONを明示的な依存関係から削除

## 2017
### 05-08
#### 2.0.2
[Added]
- Session::Abstract::SessionHash#fetchでデフォルト値のブロックを受け付けるように変更
- Builder#freeze_appを追加
  - アプリケーションとすべてのミドルウェアをfreezeする

[Changed]
- デフォルトのセッションオプションをfreeze
  - 偶発的なmutationを避けるため
- ハッシュヘッダなしで部分ハイジャックを検出できるように変更
- MiniTest6のマッチャを使用するようにテストをupgrade
- ステータスコード 205 Reset ContentレスポンスにContent-Lengthを設定できるように変更
  - RFC 7231にて0に設定することが提案されているため

[Fixed]
- multipart filenamesでnull byteを扱うように修正
- miscapitalizedなグローバルによる警告を削除
- マルチスレッドサーバのレースコンディションによる例外を防止
- RDocをdocグループの明示的な依存関係に追加
- Multipart::Parserから発生したエラーをbubble upさせずMethodOverrideミドルウェアに追記させるように変更
- 削除されたUtils#bytesizeの残りの使用をFileミドルウェアから削除

[Removed]
- deflateエンコーディングのサポートを削除
  - キャッシングのオーバーヘッドを減らすため

[Documentation]
- Deflaterのexampleを修正

### 05-15
#### 2.0.3
[Changed]
- envの値がASCII 8-bitでエンコードされていることを保証

[Fixed]
- Session::Abstract::IDからの継承をmixinしているクラスについて例外の発生を防止

## 2018
### 01-31
#### 2.0.4
[Changed]
- Lockミドルウェアが元のenvオブジェクトを渡すことを確認
- 大きなファイルをアップロードする際のMultipart::Parserのパフォーマンスを改善
- Multipart::Parserのバッファサイズを大きくしてパフォーマンスを改善
- 大きなファイルをアップロードする際のMultipart::Parserのメモリ使用量を減少
- ConcurrentRubyの依存関係をネイティブのQueueに置換

[Fixed]
- ETagミドルウェアに正しいダイジェストアルゴリズムをrequire

[Documentation]
- ホームページのリンクをSSL化

### 04-23
#### 2.0.5
[Fixed]
- 無効なUTF8から発生したエラーをMethodOverrideミドルウェアに記録

### 11-05
#### 2.0.6
[Fixed]
- [CVE-2018-16470]Multipart::Parser のバッファサイズを小さくし、pathologicalなパースを回避
- ShowExceptionsミドルウェア内に存在しない#accepts_htmlの呼び出しを修正
- [CVE-2018-16471]Request#schemeでHTTPおよびHTTPSのスキームをホワイトリスト化し、XSS攻撃の可能性を回避

## 2019
### 04-02
#### 2.0.7
[Fixed]
- Multipart::ParserのRack inputに対する#eof?の呼び出しを削除
- 信頼できるプロキシチェーンに転送されたIPアドレスを保存

### 12-08
#### 1.6.12
[Security]
- [CVE-2019-16782]セッションIDのルックアップを狙ったタイミング攻撃を防止
  - BREAKING CHANGE: セッションIDがStringではなくSessionIdインスタンスに変更

#### 2.0.8
[Security]
- [CVE-2019-16782]セッションIDのルックアップを狙ったタイミング攻撃を防止
  - BREAKING CHANGE: セッションIDがStringではなくSessionIdインスタンスに変更
