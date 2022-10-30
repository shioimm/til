# bcc (BPF Compiler Collection)
- BPFプログラムを書くためのフロントエンドツールキット
- C (LLVMによるCラッパーを含む) によるカーネルインストルメンテーションと
  Python・Lua・Goによるバインディングを備える

#### bcc tools
- bccを使ったトレーシングのツールキット
  - e.g. execsnoop - execve(2)をトレースする
  - e.g. bashreadline - bashに入力されたコマンドを表示する
  - e.g. argdict - 指定の関数をトレースし引数の値を頻度カウンタやヒストグラムとして表示する

#### bccの機能
- BPFプログラムを簡単に記述するためのModified C (BPF C) を提供する
- BPF Cのコンパイル機能
- BPFプログラムローダー
  - LLVM/Clangを用いてBPF CのASTを解析/変更した上でBPFプログラムにコンパイルし、カーネルにロードする
- BPFマップへアクセスするための関数

## 書式 (1)
- 関数`イベント名__関数名`を記述することでカーネル内部の任意の関数のイベントをフックする処理を追加できる
  - kprobes - 関数が呼び出される前に実行されるイベント
  - kretprobes - 関数から戻る時に実行されるイベント
- 第一引数は`struct pt_regs *ctx` (BPFコンテキストのレジスタ)
- 関数内ではカーネルのAPIやBCCのAPIを呼び出すことができる

```py
from bcc import BPF

bpf_text="""
// sys_clone(2)が呼び出される前に実行する処理を定義す
int kprobe__sys_clone(void *ctx) {
  bpf_trace_printk("Hello, World!\\n");
  return 0;
}
"""

BPF(text=bpf_text).trace_print()

# bpf_trace_printk()
# /sys/kernel/debug/tracing/trace_pipeに指定した文字列を出力するBCCのAPI

# trace_print()
# bpf_trace_printk()でtrace_pipeに出力されたデータを読み込んで表示する関数
```

- [`bcc/examples/hello_world.py`](https://github.com/iovisor/bcc/blob/master/examples/hello_world.py)

```py
from bcc import BPF

bpf_text="""
int hello(void *ctx)
{
  bpf_trace_printk("Hello, World!\\n");
  return 0;
}
"""

b = BPF(text=bpf_text)
b.attach_kprobe(event=b.get_syscall_fnname("clone"), fn_name="hello")
b.trace_print

// attach_kprobe()
// 指定した関数を特定のカーネル関数のkprobeイベントに紐付ける

// get_syscall_fnname()
// 実行しているマシンのカーネルのバージョンに適合した関数を呼び出す
```

## 書式 (2)
- 関数`syscall__システムコール名`をを記述することでシステムコールの引数をeBPFの中で取得することができる

```
int syscall__execve(
  struct pt_regs *ctx,
  const char __user *filename,
  const char __user *const __user *__argv,
  const char __user *const __user *__envp
)
{
  // 処理
}
```

- [8. system call tracepoints](https://github.com/iovisor/bcc/blob/master/docs/reference_guide.md#8-system-call-tracepoints)

## 参照
- [iovisor/bcc](https://github.com/iovisor/bcc)
- [BCC（BPF Compiler Collection）によるBPFプログラムの作成](https://www.atmarkit.co.jp/ait/articles/1912/17/news006.html)
- [BCCでeBPFのコードを書いてみる](https://gihyo.jp/admin/serial/01/ubuntu-recipe/0690)
