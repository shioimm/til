# BTF (BPF Type Format)
- データ構造のレイアウトや関数のシグネチャを表現するためのフォーマット
- eBPFプログラム実行時にカーネルのバージョン間の差異を自動的に調整する
  - Linuxカーネルは実行中のシステムからvmlinux.hというヘッダファイルを生成し、
    eBPFプログラムが必要とするカーネルに関するすべてのデータ構造情報を含む
  - eBPFに関するメタデータを持ち、eBPFアプリケーションがロードされる際に
    プラットフォームとなるLinuxカーネルに対して常に適切な参照を持てるように
    バイナリ内のマッピングを直接書き換える

#### Clangによるサポート
- ClangコンパイラはeBPFプログラムをコンパイルする際、BTFリロケーションを含むように改良された
- BTFリロケーション - libbpfがBPFプログラムとMapをカーネルにロードする際に調整するべき内容を表す

## 参照
- What is eBPF? Chapter 4
- [BPF Type Format (BTF)](https://www.kernel.org/doc/html/latest/bpf/btf.html)
