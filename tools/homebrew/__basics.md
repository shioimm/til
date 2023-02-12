# Homebrew
- Mac用パッケージマネージャー
- コマンドラインツールのインストールに使用する
- ex. vim, ruby-build, heroku

#### Homebrew-Cask
- Homebrewの拡張
- GUIアプリケーションのインストールに使用する
- ex. chromedriver, visual-studio-code

### Formula
- インストール用プログラム
- homebrew-coreに格納されている

### Celler (`/opt/homebrew/Celler/...`) (Apple silicon)
- インストールしたパッケージの格納場所
- `/opt/homebrew/bin/...`へのシンボリックリンクを貼ることでどこからでも呼べるようにする

#### keg-only
- インストールしてCellerに配置した後、`/opt/homebrew/bin/...`へのシンボリックリンクを作成しないパッケージ
- 必要時は明示的にPATHの設定が必要 (`$ brew link`)

## 参照
- [Homebrew Documentation](https://docs.brew.sh/)
- https://blog.mothule.com/mac/homebrew/mac-homebrew-basic
