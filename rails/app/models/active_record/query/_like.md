# LIKE句
```
# ワイルドカード ('_'でも可) を使用するLIKE検索
User.where('account like ?', '%test%')

# パラメータに含まれる'_'と'%'がワイルドカードとして扱われることを防ぐ
User.where('account like ?', ActiveRecord::Base.sanitize_sql_like(params[:account].to_s)

# '_'が含まれることのない文字列の場合はto_sのみで可
User.where('name like ?', params[:name].to_s)
```

## 参照
- [`sanitize_sql_like`](https://api.rubyonrails.org/classes/ActiveRecord/Sanitization/ClassMethods.html#method-i-sanitize_sql_like)
