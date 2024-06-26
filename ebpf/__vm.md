# eBPF仮想マシンアーキテクチャ
## 命令セット
- 各種算術演算
- ロード命令
- ストア命令
- ジャンプ命令
- リターン命令
- カーネル関数呼び出し命令
- アトミック加算命令 - 主にbpf mapのデータ構造内のデータを更新する際に利用
- エンディアン変換命令
- 64bit幅命令

#### 命令セットフォーマット
- 1命令あたり64ビット固定長
- オペコードの内のLSB3ビットで命令クラスを表し、命令クラスによって残りの5ビットの値が決まる

```c
struct bpf_insn {
  __u8  code;      // オペコード (LSB)
  __u8  dst_reg:4; // デスティネーションレジスタ
  __u8  src_reg:4; // ソースレジスタ
  __s16 off;       // オフセット (signed)
  __s32 imm;       // 即値 (signed) (MSB)
};
```

#### 命令クラス (命令の種類)

| クラス      | 値  | 説明                                      |
| -           | -   | -                                         |
| `BPF_LD`    | 0x0 | ロード命令 (特殊なユースケースにのみ使用) |
| `BPF_LDX`   | 0x1 | ロード命令 (レジスタへのロード)           |
| `BPF_ST`    | 0x2 | ストア命令 (即値をストア)                 |
| `BPF_STX`   | 0x3 | ストア命令 (レジスタからストア)           |
| `BPF_ALU`   | 0x4 | 32ビット算術命令                          |
| `BPF_JMP`   | 0x5 | 64ビットジャンプ命令                      |
| `BPF_JMP32` | 0x6 | 32ビットジャンプ命令                      |
| `BPF_ALU64` | 0x7 | 64ビット算術命令                          |

## レジスタ
- 仮想マシンのレジスタはJIT動作のためにホストCPUの実レジスタに割り当てられて利用される

#### レジスタの種類
- R0
  - 読み書き可能な汎用レジスタ
  - eBPFのプログラムおよびカーネル関数の戻り値を格納する
- R1 ~ R5
  - 読み書き可能な汎用レジスタ
  - eBPFのプログラムから呼び出すカーネル関数の引数を格納する
- R6 ~ R9
  - 読み書き可能な汎用レジスタ
- R10
  - 読み込み専用のスタックポインタ
  - スタックサイズは512バイト固定

## 参照
- [eBPF - 仮想マシン 編](https://zenn.dev/hidenori3/articles/cb8ddfb964bbc5)
- [BPFのアーキテクチャ、命令セット、cBPFとeBPFの違い](https://atmarkit.itmedia.co.jp/ait/articles/1812/10/news016.html)
