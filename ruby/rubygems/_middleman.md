# Middleman
- 参照: [Middleman](https://middlemanapp.com/jp/)
- 参照: [Middleman](https://github.com/middleman/middleman)

## TL;DR
- Ruby製の静的サイトジェネレータ

## Usage
- `$ middleman init` - 雛形を生成
  - 雛形の構成
    - `.sass-cashe`
    - `source/`
      - `images/`
      - `javascripts/`
      - `layouts/`
      - `stylesheets/`
      - `index.html.erb`
    - `config.rb`
    - `.gitignore`
    - `Gemfile`
    - `Gemfile.lock`
- `$ middleman server` - サーバーを起動
  - 動作確認のため
  - rackアプリとして起動
- `$ middleman build` - サイトの構築
  - `build/`ディレクトリにコンパイル済みの静的ファイルを生成
- `$ middleman deploy` - 本番環境へデプロイ
  - sync/FTP/SFTP/Git経由でデプロイ可能
