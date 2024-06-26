### `determine_mime_type`
- [Determine MIME Type](https://shrinerb.com/docs/plugins/determine_mime_type)
- バイナリに含まれた情報を解析し、ファイルの実際のMIMEタイプを決定して保存する
- MIMEタイプの解析ツールは変更可能(デフォルトではUNIXファイルユーティリティが実行する)

### `instrumentation`
- [Instrumentation plugin - a better "logging" plugin](https://github.com/shrinerb/shrine/issues/387)
- [Instrumentation](https://shrinerb.com/docs/plugins/instrumentation)
- イベント通知
- Shrine3系以上で削除される`logging`プラグインの上位互換として導入された
- 従来の`logging`の機能に加え、外部のロギング機能を使用できる
  - デフォルトでは`ActiveSupport::Notifications`にイベントをサブスクライブする
  - テスト環境でもサブスクライブが実行されてしまうため、使用にあたっては次のような制限を入れた
```ruby
if !Rails.env.test? || ENV['SHRINE_INSTRUMENTATION']
  Shrine.plugin :instrumentation
end
```

### `infer_extension`
- [Infer Extension](https://shrinerb.com/docs/plugins/infer_extension)
- ファイルのMIMEタイプに基づいてファイル拡張子を推測する

### `pretty_location`
- [Pretty Location](https://shrinerb.com/docs/plugins/pretty_location)
- アップロードファイルをネストされたディレクトリ構造内に保存する
```
# デフォルト

:model/:id/:attachment/:derivative-:uid.:extension
```
