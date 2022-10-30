# libbpf
- eBPFプログラムとMapをカーネルにロードするための関数を提供するライブラリ
- コンパイル時のデータ構造と移植先のマシンのデータ構造の違いを補正するため、
- ロード時にBTFとeBPFオブジェクトを適切に結びつける

## 参照
- What is eBPF? Chapter 4
- [BPF Type Format (BTF)](https://www.kernel.org/doc/html/latest/bpf/btf.html)
