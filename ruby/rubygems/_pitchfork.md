# Pitchfork
- Puma向けのプロセスマネージャ
  - プロセスの起動・停止・再起動
  - クラッシュ時の自動復旧
  - プロセスの並列管理
  - ログ管理
  - シグナル処理

```
# config/puma.rb
# 2プロセス / 最小4スレッド、最大16スレッド / ポート番号3000
workers 2
threads 4, 16
port 3000
preload_app! # ワーカをforkする前にアプリを読み込む
```

```
$ pitchfork -- puma -C config/puma.rb
```
