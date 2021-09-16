# コンテナの操作
- 起動・実行コマンドの引数に`/bin/sh` or `/bin/bash`を渡す
  - `-it`オプションを渡さないとシェルを操作できない
  - Ctrl + p -> Ctrl + qでホストに戻り、`$ docker atach NAME`で再度シェルに入る

```
# 起動前のコンテナの操作(runコマンド終了時、シェルとコンテナが終了する)
$ docker run -it --name web01 httpd:2.4 /bin/bash

# 起動中のコンテナの操作(execコマンド終了時、シェルのみが終了する)
$ docker exec -it web01 /bin/bash
```

## 参照
- さわって学ぶクラウドインフラ docker基礎からのコンテナ構築
