# ngrok
- ローカル環境のWebサーバーを公開するトンネリングツール
  - ローカル環境のNATやファイアウォールを経由し、
    安全なトンネルを介してローカルサーバーをインターネットに公開する
  - ローカル環境で稼働しているアプリケーションを、デプロイせずにデモすることができる

## ngrokの動作
1. ngrok実行時、ngrokはローカル環境へWebサーバーのポートを提供する
2. ngrokはngrokクラウドサービスに接続し、パブリックなアドレスへのアクセスを受け取る
3. ngrokは発生したアクセスをローカルマシン上で実行されているngrokプロセスに中継し、
   指定したローカルアドレスに転送する

## Usage
```
$ ngrok http 3000
```

### 起動
- アプリケーションを稼働しているローカルホストがlistenしているポート番号をngrokに渡す
- CLIに以下の情報が表示される
  - トンネルの公開URL
  - トンネル上で行われた接続に関するステータス
  - メトリクス情報など

### GUI環境
- `http://localhost:4040`

### Rails: `blocked host: xxxxxxxx.ngrok.io`

```ruby
# config/environments/development.rb

Rails.application.configure do
  config.hosts << '.ngrok.io'
end
```

## 参照
- [ngrok](https://ngrok.com/)
