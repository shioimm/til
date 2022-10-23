# BTF (BPF Type Format)
- eBPFアプリケーションをLinuxカーネルのどのバージョンに対してポータブルに実行できるようにする技術
- eBPFに関するメタデータを持ち、eBPFアプリケーションがロードされる際に
  プラットフォームとなるLinuxカーネルに対して常に適切な参照を持てるように
  バイナリ内のマッピングを直接書き換える
- [BPF Type Format (BTF)](https://www.kernel.org/doc/html/latest/bpf/btf.html)
