// Go言語で作るインタプリタ 3
package object

// 環境
type Environment struct {
  store map[string]Object
  outer *Environment
}

func NewEnvironment() *Environment {
  s := make(map[string]Object)
  return &Environment{store: s, outer: nil}
}

func NewEnclosedEnvironment(outer *Environment) *Environment {
  // 外部にouterの環境を持つ新しい環境を作る
  env := NewEnvironment()
  env.outer = outer
  return env
}

func (e *Environment) Get(name string) (Object, bool) {
  obj, ok := e.store[name]
  if !ok && e.outer != nil { // 現在の環境にnameが存在しなければouterの環境からnameを取得する
    obj, ok = e.outer.Get(name)
  }
  return obj, ok
}

func (e *Environment) Set(name string, val Object) Object {
  e.store[name] = val
  return val
}
