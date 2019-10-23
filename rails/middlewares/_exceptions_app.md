# exceptions_appの実装
- `Rails.configuration.exceptions_app`を利用して例外をハンドリングするErrorsControllerを実装する

### 概要
```
どこかのControllerで例外が発生する
 => exception_appが起動してErrorsControllerのshowアクションを呼ぶ
 => showアクションが投げた例外をrescue_fromが捕捉
 => エラーに応じて適切なメソッドが呼ばれる
 => ログにエラーを出力し、テンプレートをrender
```

### 具体的な実装内容
1. 例外発生時にErrorsController#showを呼ぶようにmiddlewareを指定
```ruby
# config/initializers/exceptions_app.rb

Rails.configuration.exceptions_app = ->(env) { ErrorsController.action(:show).call(env) }
```
2. ErrorsControllerを実装
```ruby
# errors_controller.rb

class ErrorsController < ActionController::Base
  rescue_from StandardError,                  with: :render_500
  rescue_from ActiveRecord::RecordNotFound,   with: :render_404
  rescue_from ActionController::RoutingError, with: :render_404

  def show
    raise request.env['action_dispatch.exception']
  end

  def render_500(exception = nil)
    ErrorUtility.logger exception if exception
    render 'errors/500', layout: 'application', status: 500
  end

  def render_404(exception = nil)
    ErrorUtility.logger exception if exception
    render 'errors/404', layout: 'application', status: 404
  end
end
```
3. `app/views/`直下に`errors/`ディレクトリを作り、`500.html.haml` `400.html.haml`テンプレートを追加

# exceptions_appのテスト
- ↑で実装したErrorsControllerに関して、RSpecで次を確認したい
  - 例外が発生した際、適切なhttpステータスコードを返している
  - 例外が発生した際、適切なテンプレートを表示している

## 課題
- RSpecのAnonymous Controller機能を使って、最初に例外が発生するControllerを表現したい
- Anonymous Controller機能を使用できるのはcontroller spec
- しかしcontroller specではmiddlewareをloadできないので、例外が起こった後の処理を追うことができない

## 解決策
- controller specが使えないため、request specでテストする。
- equest specにはAnonymous Controller機能がないため、最初に例外が発生するControllerを自作する必要がある。

```ruby
# errors_controller_spec.rb

require 'rails_helper'
RSpec.describe ErrorsController, type: :request do
  # Controllerの自作
  class TestController < ::ApplicationController
    # 例外を発生させるためのアクションを作成

    def routing_error
      raise ActionController::RoutingError.new('not_found')
    end

    def record_not_found
      raise ActiveRecord::RecordNotFound
    end

    def standard_error
      raise StandardError
    end
  end

  before do
    # テスト環境ではデフォルトで開発環境用のエラーページが表示されてしまうため、
    # 本番環境用のエラーページが表示されるよう、一時的に設定を変更
    Rails.application.env_config['action_dispatch.show_detailed_exceptions'] = false
    Rails.application.env_config['action_dispatch.show_exceptions']          = true

    # 例外を発生させるためのアクションを呼ぶためのルーティングを一時的に設定
    Rails.application.routes.draw do
      get '/routing_error'    => 'test#routing_error'
      get '/record_not_found' => 'test#record_not_found'
      get '/standard_error'   => 'test#standard_error'
      root to: 'users/sessions#new'
    end
  end

  after do
    # テストが終わったら、before do で一時的に設定した内容をリセットして元に戻す
    Rails.application.env_config['action_dispatch.show_detailed_exceptions'] = true
    Rails.application.env_config['action_dispatch.show_exceptions']          = false
    Rails.application.reload_routes!
  end

  let(:admin_user) { create(:admin_user) }

  describe '404 Error' do
    context 'when visit page which does not exist' do
      before { get '/routing_error' }

      it { expect(response).to have_http_status 404 }
      it { expect(response).to render_template 'errors/404' }
    end

    context 'when visit resource does not exist' do
      before { get '/record_not_found' }

      it { expect(response).to have_http_status 404 }
      it { expect(response).to render_template 'errors/404' }
    end
  end

  describe '500 Error' do
    context 'when internal server error occurs' do
      before { get '/standard_error' }

      it { expect(response).to have_http_status 500 }
      it { expect(response).to render_template 'errors/500' }
    end
  end
end
```
