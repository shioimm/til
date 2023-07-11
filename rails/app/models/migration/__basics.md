# マイグレーションファイル
#### `config.active_record.schema_format`

```ruby
# config/application.rb
# スキーマ情報をSQL (structure.sql) で保存する

config.active_record.schema_format = :sql
```

#### マイグレーション実行時のログ出力

| メソッド            | 処理                                                                        |
| -                   | -                                                                           |
| `suppress_messages` | 出力したくない処理を`suppress_messages`メソッドブロック内に書くと出力を抑制 |
| `say`               | 引数で渡したメッセージを出力                                                |
| `say_with_time`     | 受け取ったブロックを実行するのに要した時間を示すテキストを出力              |

## 参照
- [3.8 ヘルパーの機能だけでは足りない場合](https://railsguides.jp/active_record_migrations.html#%E3%83%98%E3%83%AB%E3%83%91%E3%83%BC%E3%81%AE%E6%A9%9F%E8%83%BD%E3%81%A0%E3%81%91%E3%81%A7%E3%81%AF%E8%B6%B3%E3%82%8A%E3%81%AA%E3%81%84%E5%A0%B4%E5%90%88)
