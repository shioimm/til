# 内部変数(一部)
- `$request_method`       - リクエストメソッド
- `$args` `$query_string` - クエリ文字列
- `$arg_xxx`              - クエリ文字列`?xxx=`
- `$cookie_xxx`           - Cookie`xxx=`
- `$host` `$http_host`    - ホスト名
- `$uri` `$document_uri`  - リクエストURI
- `$request_uri`          - リクエストURI(クエリ文字列を含む)
- `$http_user_agent`      - ユーザーエージェント
- `$request`              - リクエストライン
- `$server_protocol`      - HTTPプロトコル

### 変数定義
```
# server / locatioin / ifコンテキストで定義可能
set $xxx 値:
```

## 参照
- nginx実践ガイド
- [nginx連載3回目: nginxの設定、その1](https://heartbeats.jp/hbblog/2012/02/nginx03.html#more)
- [nginx連載4回目: nginxの設定、その2](https://heartbeats.jp/hbblog/2012/04/nginx04.html)
- [nginx連載5回目: nginxの設定、その3](https://heartbeats.jp/hbblog/2012/04/nginx05.html#more)
- [nginx連載6回目: nginxの設定、その4](https://heartbeats.jp/hbblog/2012/04/nginx06.html#more)
