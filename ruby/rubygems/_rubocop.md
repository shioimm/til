# Rubocop
- [rubocop-hq/rubocop](https://github.com/rubocop-hq/rubocop)
- 参照: パーフェクトRuby on Rails[増補改訂版] P418-423

## 種類
- Layout   - インデントやスペース
- Lint     - バグの可能性
- Metrics  - コードの複雑さ
- Naming   - メソッド名や定数名など
- Security - 脆弱性
- Style    - コーディング規約

## 実行オプション
- 自動修正
```
$ rubocop -a
```

- copの指定
```
$ rubocop --only 指定するcop
```

- Lint Copの実行
```
$ rubocop -l
```

- `rubocop_todo.yml`の生成
```
$ rubocop --auto-gen-config

# Layout/LineLengthのMax値を
# プロジェクト内の最大値ではなく.rubocop.ymlに指定の値へ統合する場合のワンライナー
$ rubocop --auto-gen-config --auto-gen-only-exclude --exclude-limit 99999
```
