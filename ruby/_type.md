# 型
- [ruby/rbs](https://github.com/ruby/rbs)
  - 型情報記述言語
- [ruby/typeprof](https://github.com/ruby/typeprof)
  - 型解析ツール
  - rbsファイルの自動生成
- [soutaro/steep](https://github.com/soutaro/steep)
  - 型検査ツール

#### プロジェクトのファイル構成
```
./
 ├── lib/  # プロダクションコード
 ├── sig/  # RBS
 ├── test/ # テスト
 └── Steepfile # steepの設定ファイル
```

#### RBSファイルの自動生成 (typeprof)

```
$ typeprof test/PROGRAM_NAME_test.rb -o sig/PROGRAM_NAME.rbs
```

#### 型検査

```
# Steepfileの作成
$ steep init

# 型検査の実行
$ steep check
```
