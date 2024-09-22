# Bundlerが接続を確立するまで
- `lib/bundler/vendored_net_http.rb`
  - `net/http`をrequireして`Net::HTTP`を`Gem::Net::HTTP`として扱えるようにする
- `lib/bundler/vendor/net-http-persistent/lib/net/http/persistent.rb`
  - `vendored_net_http`をrequire
  - `Gem::Net::HTTP::Persistent#request`
    - リクエスト`#<Gem::Net::HTTP::Get GET>`をつくる (条件付き) (`Gem::Net::HTTP::Persistent#request_setup`)
    - `Gem::Net::HTTP::Persistent#connection_for`を呼び出し、ブロックの中でリクエストを処理する
  - `Gem::Net::HTTP::Persistent#connection_for`
    - `#<Gem::Net::HTTP::Persistent::Pool>`からコネクションを払い出す
    - `Gem::Net::HTTP::Persistent#start`に
      コネクションの持つ`Gem::Net::HTTP`オブジェクト`#<Gem::Net::HTTP gem.repo4:443 open=false>` を
      渡して呼び出す(条件付き)
- `lib/bundler/fetcher.rb`
  - `Bundler::Fetcher#connection`
    - `Gem::Net::HTTP::Persistent.new`の返り値 (con) にいろいろ設定して返している
  - `Bundler::Fetcher#downloader`
    - `Bundler::Fetcher::Downloader.new`に`Bundler::Fetcher#connection`を渡している
  - `Bundler::Fetcher#fetch_spec`
    - `Bundler::Fetcher#downloader`に対して`Bundler::Fetcher::Downloader#fetch`を呼び出している
- `lib/bundler/fetcher/downloader.rb`
  - `Bundler::Fetcher::Downloader#fetch`
    - `Bundler::Fetcher::Downloader#request`を呼び出している
  - `Bundler::Fetcher::Downloader#request`
    - `Bundler::Fetcher#connection`に`Gem::Net::HTTP::Persistent#request`を呼び出している
