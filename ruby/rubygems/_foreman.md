# Foreman
- 参照: [Foreman](https://github.com/ddollar/foreman)
- 参照: [Introducing Foreman](http://blog.daviddollar.org/2011/05/06/introducing-foreman.html)
- 参照: [foremanとはなんでしょうか　使う利点は？](https://ja.stackoverflow.com/questions/17831/)

## TL;DR
- 複数のプロセスをまとめて管理するツール
  - 対象のプロセスの種類とコマンドはProcfileに記述する

### 利点
- Procfileベースで対象のプロセスをまとめて立ち上げることができる
- 対象のプロセスのログをまとめて標準出力することができる
- Procfileベースでチーム内の開発ツールを同期することができる

## Usage
```
# Procfile

web:    bundle exec thin start -p $PORT
worker: bundle exec rake resque:work QUEUE=*
clock:  bundle exec rake resque:scheduler
```

- Procfileの内容を確認する
```
$ foreman check
```

- 起動する
```
$ foreman start
```

- アプリケーションを別のプロセス管理フォーマットに出力する
```
# フォーマット
  - bluepill
  - inittab
  - launchd
  - runit
  - supervisord
  - systemd
  - upstart
```
```
$ foreman export フォーマット 出力先のパス
```
