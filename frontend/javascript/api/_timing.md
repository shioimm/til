# Timing API
## Navigation Timing API
- [Navigation Timing API](https://developer.mozilla.org/ja/docs/Web/API/Navigation_timing_API)
- ブラウザがルートドキュメントが表示される時間を計測するAPI
- 計測結果はブラウザの開発者ツール(Performance)に表示する

## Resource Timing API
- [Resource Timing API](https://developer.mozilla.org/ja/docs/Web/API/Resource_Timing_API)
- ブラウザがルートドキュメントからリンクされたリソースを読み込むまでの時間を計測するPI
- 計測結果はブラウザの開発者ツール(Performance)に表示する

## User Timing API
- [User Timing API](https://developer.mozilla.org/ja/docs/Web/API/User_Timing_API)
- 精度の高いタイマーでアプリケーション特有の指標をマーキングし計測するAPI
  - `performance.mark()` - マーキングしたい地点を指定する
  - `performance.measure()` - マーク間の経過時間を取得する
- 計測結果はブラウザの開発者ツール(Performance)に表示する

## 参照
- ハイパフォーマンスブラウザネットワーキング
