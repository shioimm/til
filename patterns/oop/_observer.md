# Observer
- あるオブジェクト (Subject) の状態が変化した際、
  そのオブジェクトを観察する別のオブジェクト群 (Observer) がコールバックを実行するような仕組みをつくる
- ObserverはSubjectに対して自らを観察対象としてアタッチ・デタッチすることができる
- Subjectは自らの状態が変化した際にObserverに対して通知を行う
- ObserverはSubjectからの通知を受け取るための統一的なインターフェースを持つ (Adapter)
- Observerの種類によって通知をフィルタリングするためにはStrategyが必要

## 参照
- オブジェクト指向のこころ 第18章
