# 共有ライブラリ
- ひとつのオブジェクトモジュールを全実行ファイルで共有するためのファイル
- オブジェクトモジュールを実行ファイルへコピーせず共有ライブラリ間で別途管理する
- プログラムに共有ライブラリをリンクしても
  実行ファイルはオブジェクトモジュールをコピーせず、
  そのモジュールを必要とするプログラムを初めて実行した際にライブラリをメモリへロードする
  - その後に同じモジュールを使用する他のプログラムを実行すると、
    メモリにロード済みのライブラリを使用する
- 共有ライブラリには作成時にELFヘッダが付与される
  - ELFヘッダはsonameを含む

### 利点
- 実行ファイルが消費するディスク容量・実行時の仮想メモリサイズを削減できる
- プログラムサイズ全体を削減できる -> プログラムのメモリへのロード時間を短縮できる
- オブジェクトモジュールを変更した場合、
  リンクしている実行ファイルに対して再リンクせずに変更を反映させることができる

### 欠点
- スタティックライブラリよりも複雑化する
- PICでコンパイルする必要がある
- 実行時にシンボル再配置を行い、共有ライブラリ内でのシンボル参照を
  仮想メモリ内の実行時配置に対応させる必要がある
  - 再配置処理のためスタティックライブラリのリンクよりも若干時間がかかる

### ELF形式
- Executable and Linking Format
- UNIXシステムで実行ファイル・共有ライブラリに採用されているファイル形式
- `a.out` / COFF形式を置き換えるもの

### PIC
- 位置独立コード(配置非依存コード)
- 仮想アドレス空間内のどこへでも配置可能であり、実行時に動的に位置を決定するコード
- PICはレジスタを余計に使用するためオーバーヘッドを伴う

### 作成方法
#### スタティックライブラリを共有ライブラリ化する
```
# プログラムをコンパイルし、オブジェクトモジュールを作成
$ gcc -g -c -fPIC -Wall mod1.c mod2.c mod3.c

# オブジェクトモジュールを共有ライブラリにまとめる
$ gcc -g -shared -o libfoo.so mod1.o mod2.o mod3.o

# 上記を一度に行う
$ gcc -g -fPIC -Wall mod1.c mod2.c mod3.c -shared -o libfoo.so
```

#### 標準規約に沿って共有ライブラリを作成する
```
# プログラムをコンパイルし、オブジェクトファイルを作成
$ gcc -g -c -fPIC -Wall mod1.c mod2.c mod3.c

# real nameがlibrealname.so.1.0.1、sonameがlibsoname.so.1の共有ライブラリを作成
$ gcc -g -shared -Wl,-soname,libsoname.so.1 -o librealname.1.0.1 mod1.o mod2.o mod3.o

# soname / linker nameのシンボリックリンクを作成
$ ln -s librealname.so.1.0.1 libsoname.so.1
$ ln -s libsoname.so.1 libliknername.so

# プログラムを実行
$ gcc -g -Wall -o prog prog.c -L -llinkername
$ LD_LIBRARY_PATH=. ./prog
```

### 実行ファイルへのリンク方法
- 実行時に必要となる共有ライブラリを特定する
  - 実行ファイルリンク時に共有ライブラリ名が埋め込まれる
    - ELFでは依存ライブラリを`DT_NEEDED`タグをつけ実行ファイル内に埋め込む
  - ダイナミック依存リスト - プログラムが依存するライブラリ一覧
- 実行時に埋め込まれた共有ライブラリ名を解決し、メモリへロードする(ダイナミックリンク)

#### ダイナミックリンカ(ダイナミックリンクローダー)
- 共有ライブラリ`/lib/ld-linux.so.2`
- 共有ライブラリを使用する全てのELF実行ファイルのダイナミックリンクを行う
- 実行ファイルが必要とする共有ライブラリ一覧を検査し、
  規定の規則に従ってファイルシステム内のライブラリファイルを検索する

#### ダイナミックリンカの検索対象ディレクトリ
- `/usr/lib` - 最も標準的なライブラリをインストールするディレクトリ
- `/lib` - システム起動時に必要なライブラリをインストールするディレクトリ
- `/usr/local/lib` - 非標準・開発中のライブラリをインストールするディレクトリ
- `etc/ld.so.conf`に記述したディレクトリ
- プログラム実行時に環境変数`LD_LIBRARY_PATH`で指定されたディレクトリ
- スタティックリンク時に実行ファイル内に埋め込まれたパスの指すディレクトリ
  - `$ gcc -g -Wall -Wl,-rpath,/path/to/dir -o prog prog.c libdemo.so`
  - `-rpath`オプションは別ディレクトリに置かれた別共有ライブラリに依存する
    共有ライブラリとのリンクにも使用できる

### soname
- 実行ファイルに埋め込まれる共有オブジェクトライブラリ名
- 共有ライブラリ作成時に名前を指定することができる
- sonameを指定していない共有ライブラリの場合、
  ダイナミックリンク時に実行ファイルに
  共有ライブラリファイルの実際の名前(real name)が埋め込まれる

```
# 共有ライブラリlibfoo.soにsonameとしてlibbar.soをつけるようリンカに指示
$ gcc -g -shared -Wl -soname, libbar.so -o libfoo.so mod1.o mod2.o mod3.o

# 既存の共有ライブラリのsonameを確認する
$ objdmp  -p libfoo.so | grep SONAME
$ readelf -d libfoo.so | grep SONAME

# sonameを持つ共有ライブラリをプログラムにリンクして実行ファイルを作成
# (リンカが実行ファイルにsonameであるlibbar.soを埋め込む)
$ gcc -g -Wall -o prog prog.c libfoo.so

# ダイナミックリンカがlibbar.soを解決できるようにするため、
# real nameであるlibfoo.soへのシンボリックリンクをsonameで作成
$ ln -s libfoo.so libbar.so

# プログラムを実行
$ LD_LIBRARY_PATH=. ./prog
```

### バージョン命名規則
- real name - `librealname.so.major-id.minor.id`
  - ライブラリコードを持つファイル
  - メジャーバージョン + マイナーバージョンにつき一つ存在する
- soname - `libsoname.so.major-id`
  - メジャーバージョンにつき一つ存在する
  - 実行ファイルとのリンク時に埋め込まれ、実行時に検索される名前
  - 最新バージョンのreal nameへのシンボリックリンク
  - real nameのライブラリと同じディレクトリ下に相対パスのシンボリックリンクとして作成される
  - real nameと同じメジャーバージョンでの最新マイナーバージョンを指す
- linker name - `libliknername.so`
  - バージョンに依存しない共有ライブラリと実行ファイルとのリンクに使用される名前
  - バージョンを問わず一つだけ存在する
  - 最新バージョンのreal nameへのシンボリックリンク

### 課題
- 共有ライブラリは様々なディレクトリへ置かれる
- 新バージョンのライブラリがインストールされたり、
  旧バージョンのライブラリが削除されたりした際、
  sonameのシンボリックリンクが取り残される可能性がある

### 実行時シンボル解決
- メインプログラム内のグローバルシンボル定義はライブラリ内の定義よりも優先する
- グローバルシンボルが複数のライブラリ内で定義されている場合、
  スタティックリンク時に指定されたライブラリの並びを左から右へ検索し、
  最初に認識した定義を優先する
- 共有ライブラリ内でのグローバルシンボル参照にライブラリ内での定義を優先する場合は
  共有ライブラリビルド時に`-Bsymbolic`オプションを与える

## 共有ライブラリの初期化・終了処理
- 共有ライブラリのロード・アンロード時に実行する関数を実装することができる

```c
// 初期化処理
void __attribute__((constructor)) some_name_load(void)
{
  // 初期化処理を記述する
}

// 終了処理
void __attribute__((destructor)) some_name_unload(void)
{
  // 終了処理を記述する
}
```

## プリロード
- プログラム実行時、環境変数`LD_PRELOAD`に共有ライブラリ名を設定すると
  他の共有ライブラリより先にロードされるようになる
  - 先にロードされるため、実行ファイルはそのライブラリ内で定義した関数を
    優先的に参照するようになる

```
$ LD_PRELOAD=libalt.so ./prog
```

- `/etc/ld.so.preload`ファイルにライブラリ名を指定することで
  システム全体に作用するライブラリのプリロードも可能

## ダイナミックリンカのトレース
- プログラム実行時、環境変数`LD_DEBUG`に規定の値を設定すると
  ダイナミックリンカは自身の動作のトレース情報を出力する
  - `help` - `LD_DEBUG`のヘルプ情報
  - `libs` - ライブラリ検索パス
  - `reloc` - 再配置処理
  - `files` - 入力ファイル処理
  - `symbols` - シンボルテーブル処理
  - `bindings` - シンボルバインド情報処理
  - `versions` - バージョン依存関係
  - `all` - 上記全て
  - `statistics` - 再配置統計情報
  - `unused` - 未使用のDSO(dynamically-linked shared object)を特定する

## 参照
- Linuxプログラミングインターフェース 2章 / 41章