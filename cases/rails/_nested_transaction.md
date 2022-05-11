# ネストしたトランザクション
- トランザクションをネストしているとき、
  RDBMSによりネストした内側のトランザクションで例外が発生した際に
  外側のトランザクションで当該例外が無視され、ロールバックされない場合がある
- ネストした内側のトランザクションで発生した例外に対してロールバックを行う場合、
  明示的に`joinable: false, requires_new: true`を指定する

```ruby
ActiveRecord::Base.transaction(joinable: false, requires_new: true) do
  # inner code
end
```

## 参照
- [【翻訳】ActiveRecordにおける、ネストしたトランザクションの落とし穴](https://qiita.com/jnchito/items/930575c18679a5dbe1a0)
- [Nested transactions](https://api.rubyonrails.org/classes/ActiveRecord/Transactions/ClassMethods.html#module-ActiveRecord::Transactions::ClassMethods-label-Nested+transactions)
