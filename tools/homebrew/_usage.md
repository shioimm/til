# Udage
#### ソースコードの確認

```
$ brew edit <FormulaName>
```

#### インストール済みバージョンを切り替える

```
$ brew unlink <FormulaName>
$ brew link <FormulaName>@<VersionNum>
```

```
# switchは削除済み
$ brew switch <FormulaName> <VersionNum>
Error: Unknown command: switch
```

#### インストールされているソフトを確認する
- Caskで入れているものも確認できる

```
$ brew search <FormulaName>
```

####  Third-Party RepositoriesのライブラリをHomebrew経由でインストールする
- [Taps (Third-Party Repositories)](https://docs.brew.sh/Taps)

```
$ brew tap <FormulaName>
```

#### \<FormulaName>に依存しているFormulaを確認する

```
$ brew uses <FormulaName>
```

#### \<FormulaName>が依存しているFormulaを確認する
- `--tree` - 依存先をツリー表示

```
$ brew deps <FormulaName>
```

## 参照
- [Homebrew Documentation](https://docs.brew.sh/)
