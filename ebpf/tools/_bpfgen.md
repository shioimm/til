# bpfgen
- ユーザー空間からBPFプログラムのライフサイクルを管理することができる関数群
  - BPFプログラムのライフサイクル - カーネルへのロード、イベントへのアタッチなど
- コンパイルされたBPFオブジェクトファイルから`bpftool gen skeleton`を使って自動生成することができる

## 参照
- What is eBPF? Chapter 4
- [BPF Type Format (BTF)](https://www.kernel.org/doc/html/latest/bpf/btf.html)
