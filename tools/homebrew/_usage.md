# Udage
#### `$ brew link xx` / `$ brew unlink xx`
- インストール済みバージョンの切り替え

```
$ brew unlink xx
$ brew link xx@VERSION
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