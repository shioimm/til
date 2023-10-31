# GVLに関するメモ
- Global VM Lock -> `thread_sched`
- Rubyスレッドのための排他ロック
  - VM単位でロックを行うため、一度に実行できるスレッドは常に一つになる
  - ロック中であっても、スレッドがIO待ちの間は明示的にロックを解放し、
    別のスレッドにロックを明け渡す

#### GVLの導入による利点
- シングルスレッドのパフォーマンスが向上する
- 拡張を統合しやすい
- ロックをかけないVMの方が作りやすい

#### GVLの影響を受けない処理
- `rb_thread_call_without_gvl` / `rb_thread_call_without_gvl2`で呼び出す関数
- コマンド実行
  - `sleep(1)`
- IO処理
  - `read(2)` / `write(2)`
- 外部サービス呼び出し
  - HTTPリクエスト
  - DBアクセス

#### GVLの影響を受ける処理
- `rb_thread_call_without_gvl` / `rb_thread_call_without_gvl2`で呼び出されていない関数
- Rubyアプリケーションコード実行

#### 参照
- [スレッド](https://docs.ruby-lang.org/ja/latest/doc/spec=2fthread.html)
- [Rubyのスケール時にGVLの特性を効果的に活用する（翻訳）](https://techracho.bpsinc.jp/hachi8833/2020_05_27/92042)
- [Rubyのスレッドで並列化するのに向いている処理を調べてみる](https://tech.unifa-e.com/entry/2017/06/08/200151)
