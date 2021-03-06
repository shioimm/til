# 安全なWebアプリケーションの作り方(脆弱性が生まれる原理と対策の実践) まとめ
- 徳丸浩 著

## 11 OSコマンド呼び出しの際に発生する脆弱性
- シェル経由でOSコマンドを実行する場合
- 開発に用いた機能が内部的にシェルを利用している場合

### OSコマンドインジェクション
- 発生箇所: シェルを呼び出す機能のある関数を実行している箇所
- 影響範囲: 全てのページ
- 影響の種類: 情報漏洩、データの改ざん・削除、外部への攻撃、システムの停止
- 影響度合い: 大
- 利用者関与の範囲: 不要
- 対策:
  - シェル呼び出し機能のある関数の利用を避ける
  - シェル呼び出し機能のある関数に外部からのパラメータを渡さない
  - OSコマンドに渡すパラメータを安全な関数にエスケープする

#### 事例
```
# 典型的なシナリオ
1. 攻撃用ツールを外部からダウンロード
2. ダウンロードしたツールに実行権限を付与
3. OSの脆弱性を内部から攻撃して管理者権限を得る
```
- シェルを呼び出す機能のある関数を実行している箇所への入力に
  複数コマンドを実行できるメタ文字を挿入し、任意のコマンドを実行する
- シェルを呼び出す機能のある関数を実行している箇所への入力に
  コマンドが実行できるオプションを挿入し、任意のコマンドを実行する

#### 原因
- シェル経由でOSコマンドを実行する際に、複数コマンドを実行できるメタ文字がエスケープされていない
  - メタ文字によって本来のコマンドに加えて任意のコマンドが実行される
- シェル呼び出し機能のある関数を利用している
- シェル呼び出し機能のある関数に外部からのパラメータを渡している

#### 対策
- OSコマンドの呼び出しを行わない実装方法を選択する
- OSコマンドの呼び出す際にシェルを経由しない関数を利用する
- 外部から入力された文字列をコマンドラインのパラメータに渡さない
- OSコマンドに渡すパラメータを安全な関数によりエスケープする
  - 安全なエスケープを行えるライブラリを使用する
  - OSコマンドに渡すパラメータをシェルの環境変数経由で渡す
- 保険的な対策
  - パラメータの検証 / 使用できる文字種の限定
  - アプリケーションの稼働するユーザー権限を最小限にする
  - WebサーバーのOSやミドルウェアのパッチ適用
