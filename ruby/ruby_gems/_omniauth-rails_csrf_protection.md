# omniauth-rails_csrf_protection
- 参照: [omniauth-rails_csrf_protection](https://github.com/cookpad/omniauth-rails_csrf_protection)
- 参照・引用: パーフェクトRuby on Rails[増補改訂版] P292-293

## TL;DR
- RailsでOmniAuthを使用する際に必要なCSRF脆弱性対策を行うためのgem
  - OmniAuthは`/auth/:provider`リンクを通じてサービスプロバイダの認証画面に遷移する
  - この時、`/auth/:provider`に対してCSRF対策が実施されていないと、ユーザーの気づかないうちに
    悪意のあるアカウントでOmniAuthによるソーシャルアカウントが追加されてしまう危険がある
    - CVE-2015-9284
  - `omniauth-rails_csrf_protection`は
    Railsの`ActionController::RequestForgeryProtection`を使用するCSRFトークンの検証を実装する

## Usage
- OmniAuthを使用する`link_to`に`method: :post`を追加する
