# rack-mini-profiler

### rack-mini-profilerを一時的にon/offしたい
- 参照: [How to disable Rack-Mini-Profiler temporarily?](https://stackoverflow.com/a/12507027)

- URLの末尾に次のクエリをつけてアクセスする
```ruby
# offにしたい

?pp=disable
```
```ruby
# onにしたい

?pp=enable
```
