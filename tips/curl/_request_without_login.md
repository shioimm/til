# ログインしないとアクセスできないエンドポイントへログインなしでcurlする
- curlの`-b`オプションで対象のWebサイトへ送信しているリクエストCookieを送信する
1. Cookieの値を取得
    - EditThisCookieで対象Webサイトへ送信しているCookieからセッションの値を取得する
2. 対象サイトにCookieと一緒にリクエストを送信
    - `curl /path/to/target -b "_アプリケーション名_session=セッションの値"`
