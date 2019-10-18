## form_with(model: nil, scope: nil, url: nil, format: nil, \*\*options, &block)
### フォーム送信後に画面がレンダリングされない
- レコードの生成失敗時、`render :(テンプレート)`を実行しようとした際に発生
- Ajaxを使用しないフォーム送信
- エラーは無く、ログ上ではレンダリングが実行されている
- -> `form_with`ではデフォルトでAjaxを使用するため、オプション`local: true`の追記が必要
