# Udage
#### `$ brew link xx` / `$ brew unlink xx`
- インストール済みバージョンを切り替える

```
$ brew unlink xx
$ brew link xx@VERSION
```

```
# switchは削除済み
$ brew switch xx VERSION
Error: Unknown command: switch
```

#### `$ brew search xx`
- インストールされているソフトを確認する
- Caskで入れているものも確認できる

#### `$ brew tap`
- Third-Party RepositoriesのライブラリをHomebrew経由でインストールする
- [Taps (Third-Party Repositories)](https://docs.brew.sh/Taps)

#### `$ brew uses xxx`
- `xxx`に依存しているフォーミュラを確認する

#### `$ brew deps xxx`
- `xxx`が依存しているフォーミュラを確認する
- `--tree` - 依存先をツリー表示

## 参照
- [Homebrew Documentation](https://docs.brew.sh/)
