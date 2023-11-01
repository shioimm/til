# Rails6.0.0 バージョンアップメモ

## Todo
1. Rails5.2.3にアップデート / テスト・動作確認
    - [CHANGELOG](https://weblog.rubyonrails.org/2019/3/28/Rails-5-2-3-has-been-released/)を確認
2. gemのバージョンを最新にアップデート
    - 不要なgemは削除
3. Rails6.0.0にアップデート / テスト・動作確認
    - [Ruby on Rails 6.0 リリースノート](https://railsguides.jp/6_0_release_notes.html)を確認
    - [Rails アップグレードガイド](https://railsguides.jp/upgrading_ruby_on_rails.html#rails-5-2%E3%81%8B%E3%82%89rails-6-0%E3%81%B8%E3%81%AE%E3%82%A2%E3%83%83%E3%83%97%E3%82%B0%E3%83%AC%E3%83%BC%E3%83%89)を確認

## 作業ログ
1. Rails5.2.3アップデート対応
    -  Gemfileを更新(`gem 'rails', '~> 5.2.3'`)
    - `$ bundle update rails`
    - テスト・動作確認
2. dependabotでPRが立っているgemをupdate
    - マイナーバージョン  -> メジャーバージョン
    - 【別issue】Sidekiq6.0へのupdateに伴い、RedisToGoから他のアドオンへ移行を検討（Redisのバージョンが対応していなかった）
3. featureブランチで Gemfileを更新(`gem 'rails', '~>  6.0.0'`)
4. `$ bundle update rails` -> 失敗
    - updateが必要なgemがひたすらエラーを吐いてくるので別PRでupdate対応
    - Rails 6.0.0対応していなかった`rescue_unique_constraint`を自分のアカウントにフォーク
      gemspecを6.0.0に書き換え、Gemfileを更新（公式にPRは出ていたがマージされていなかった）
5. `$ bundle update rails` -> 成功
6. `$ rails app:update`
    - 一旦全部上書きしてコミット
    - diffを見ながら必要な設定を戻してコミット
7. テスト・サーバー起動・動作確認で発生したトラブルに対応
    - `Update autoloader & Change config.active_record.belongs_to_required_by_default to be false`
    - `Update rspec-rails to 4.0.0.beta2`
    - `Remove chosen-rails & Yarn add chosen-js`
    - `Fix specs & routing`
8. DEPRECATION WARNINGを消す

## 発生したトラブル
#### Routing関連
- `ArgumentError: Invalid route name, already in use: 'root'`
- 【原因】routes.rbでroleごとに複数のrootを設定しているため
- 【解決】1. `root to: xx#yy, as: :xx_root`でroleごとにroot名を変える
- 【解決】2. `root 'users/sesions#new'`で`root_path`を設定する(未ログイン時のリダイレクト先設定)

#### Devise関連
- `NameError: uninitialized constant CustomFailureApp`
- 【原因】`$ rails app:update`時にオートローダーの設定を上書きしていたため
- 【解決】オートローダーの設定を元に戻す

#### Rspec関連
- `ActionView::Template::Error wrong number of arguments (given 2, expected 1)`
- 【原因】rspec-rails3.8がRails6非対応のため
- 【解決】 `gem 'rspec-rails', '4.0.0.beta2'`にupdate

#### ActiveRecord関連
- 子レコードが`belongs_to`で参照している親レコードが存在しない場合（idが無い場合）バリデーションがfalseになりテストが落ちる
- 【原因】`belongs_to`にデフォルトでnilチェックが入るようになったため
- 【解決】コードの見直しを前提に一時的に`config.active_record.belongs_to_required_by_default = false`を設定

#### AssetsPipeline関連
- `chosen`のアセットパスが消える
- 【原因】謎
- 【解決】アセットパイプラインからchosen-railsを参照するのをやめ、nodeに`chosen-js`を追加する
  - `yarn add chosen-js`
  - app/javascript/packs/applications.jsに`chosen-js`と`chosen-js/chosen.min.css`をimport
  - application.html.hamlを修正
    - `javascript_include_tag, 'data-turbolinks-track' => 'reload', defer: true`の直下に`javascript_pack_tag 'application', defer: true`を追記
  - app/assets/javascripts/application.js とapp/assets/stylesheets/application.scss から`chosen`の記述を削除
  - `gem 'chosen'`を削除して`bundle install`
