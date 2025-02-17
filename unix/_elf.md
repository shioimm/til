# ELF (Executable and Linkable Format)
- GNU/Linuxにおける標準バイナリフォーマット
  - コンパイラが生成するオブジェクト (オブジェクトファイル`.o`) と
    ライブラリとリンクされた実行ファイル (共有オブジェクト`.so`) において共通して用いられる
- 従来使用されていた`a.out` / `COFF`形式の後継
- 動的な共有ライブラリの利用とC++のサポートが容易
- ELFのヘッダ情報としてELF形式のバイナリやアーカイブのシンボルなどが含まれる

#### ELFヘッダ

```c
typedef struct {
  unsigned char e_ident[EI_NIDENT]; // マジック、クラス、データ、バージョン、OS/ABI、ABIバージョン
  Elf64_Half    e_type;             // ファイルタイプ
  Elf64_Half    e_machine;          // マシン
  Elf64_Word    e_version;          // バージョン
  Elf64_Addr    e_entry;            // エントリポイントアドレス
  Elf64_Off     e_phoff;            // プログラムヘッダ始点
  Elf64_Off     e_shoff;            // セクションヘッダ始点
  Elf64_Word    e_flags;            // フラグ
  Elf64_Half    e_ehsize;           // このヘッダのサイズ
  Elf64_Half    e_phentsize;        // プログラムのヘッダサイズ
  Elf64_Half    e_phnum;            // プログラムヘッダ数
  Elf64_Half    e_shentsize;        // セクションヘッダサイズ
  Elf64_Half    e_shnum;            // セクションヘッダ数
  Elf64_Half    e_shstrndx;         // セクション名のストリングテーブル
} Elf64_Ehdr;
```

#### プログラムヘッダ

```c
typedef struct {
  Elf64_Word  p_type;   // セグメントタイプ
  Elf64_Word  p_flags;  // セグメントフラグ (Flag)
  Elf64_Off   p_offset; // セグメントオフセット
  Elf64_Addr  p_vaddr;  // 仮想Addr
  Elf64_Addr  p_paddr;  // 物理Addr
  Elf64_Xword p_filesz; // ファイルサイズ (FileSiz)
  Elf64_Xword p_memsz;  // メモリサイズ (MemSiz)
  Elf64_Xword p_align;  // アライメント (Align)
} Elf64_Phdr;

```

## 参照・引用
- [Executable and Linkable Format](https://ja.wikipedia.org/wiki/Executable_and_Linkable_Format)
- [実行ファイル形式のELFって何？](https://www.itmedia.co.jp/help/tips/linux/l0448.html)
