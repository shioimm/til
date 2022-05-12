# Request Timeout
- [Heroku] Puma Pool Usageが逼迫している場合はリクエスト数に対してプロビジョニングが足りていないため、
  Dynoの台数を増やすことを検討する
  - [Puma Pool Usage](https://devcenter.heroku.com/articles/language-runtime-metrics-ruby#puma-pool-usage)
- そうでない場合はDBアクセスまたは外部のIOアクセスに原因がある可能性がある
  - ログ収集基盤ツールを利用して対象日について"Request timeout"で該当のログを検索する
  - 外部サービスに関連する箇所である場合は外部サービスのインシデント情報を確認する
  - `request_id`で対象のリクエストを絞り込む

## Request Timeoutしていない遅いリクエスト
- `/[0-9]{5,}ms/`でログを検索
- `ログの出力時刻 - リクエストにかかった秒数`時点のログを出力し、Web dynoの番号でリクエストを特定する
