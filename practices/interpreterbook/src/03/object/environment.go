// Go言語で作るインタプリタ 3
package object

// 環境
type Environment struct {
  store map[string]Object
  outer *Environment
}

func NewEnclosedEnvironment(outer *Environment) *Environment {
  env := NewEnvironment()
  env.outer = outer
  return env
}

func NewEnvironment() *Environment {
  s := make(map[string]Object)
  return &Environment{store: s, outer: nil}
}

func (e *Environment) Get(name string) (Object, bool) {
  obj, ok := e.store[name]
  if !ok && e.outer != nil {
    obj, ok = e.outer.Get(name)
  }
  return obj, ok
}

func (e *Environment) Set(name string, val Object) Object {
  e.store[name] = val
  return val
}
