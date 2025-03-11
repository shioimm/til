# Bundler
- プロセス単位でライブラリが混ざらないようにアイソレートするライブラリ
  - `gem`コマンドのラッパーツール
    - rubygemsとBundlerでDependency Resolverのバージョンが異なる
      - `gem install`したときとGemfileを使用した時で依存関係が変わる可能性がある

## Gemfile.lock
- BUNDLED WITH
  - Bundler自身のバージョン
  - `bundle install`時に更新される

## 参照
- [Bundler](https://bundler.io/)
