# YAMLファイル
## リスト
- 配列形式のデータ構造
```yml
- a
- b
- c

# => ["a", "b", "c"]

- a
-
  - b
- c

# => ["a", ["b"], "c"]
```

## マップ
- キーと値のペアを一つ以上持つオブジェクト
```yml
A: a
B:
   C: c
D:
  - d
- E: e

# => { "A" => "a", "B" => { "C" => c }, "D" => ["d"] }
#    [{ "E" => "e" }]
```

## スカラ
- リスト・マップ以外のデータ型
  - 真偽値
  - NULL値
  - 整数
  - 浮動小数点数
  - 文字列

## 改行
```yml
run: | # \nで行を結合する
  echo 'Hello' >> README.md
  cat README.md
```

## アンカー - エイリアス
```yml
default: &default_filters # アンカーの定義(&)
  branches:
    only: /.*/
  tags:
    only: /.*/

workflows:
  main:
    jobs:
      - test:
        filters: *default_filters # アンカーの呼び出し(*)
      - deploy:
        filters:
          <<: *default_filters # アンカーの呼び出しをマップに対してマージ
          branches:
            only: /master/
```

## 参照・引用
- CitrcleCI実践入門 2.3
