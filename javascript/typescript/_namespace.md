# namespace

```ts
// Foo.ts
namespace Foo {
  export function foo(arg: string): string {
    return arg
  }
}

// Bar.ts
namespace Bar {
  Foo.foo('string')
}
```

- namespaceブロック内で明示的にエクスポートされていないコードはブロック内でプライベートなものになる
- namespaceはネスト可能
- 同じnamespaceの同名の関数のエクスポートの競合は不可能
  - 同名の関数がオーバーロードされたものである場合は可能

## 参照
- プログラミングTypeScript
