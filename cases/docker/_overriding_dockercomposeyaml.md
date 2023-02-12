# docker-compose.yamlの一部設定を上書きする
- `docker-compose`コマンドはデフォルトでdocker-compose.ymlを読み込みにいく
- `-f`オプションを重ねて利用することで一部の設定をマージする (後勝ち)

```
$ docker-compose -f docker-compose.yml -f docker-compose.override.yml up
```
