# スタティックライブラリ(アーカイブ)
- オブジェクトファイルのコピーをすべて包含したファイル
  - 内部のオブジェクトファイルにはいくつかの属性が付与される
    - ファイルパーミッション
    - ユーザーID
    - グループID
    - 最終更新時刻
- プログラムにスタティックライブラリをリンクすると、
  実行ファイルは必要なオブジェクトファイルのコピーを内部に包含する

### 利点
- 広く利用する複数のオブジェクトファイルを一つのライブラリファイルにまとめる
  -> アプリケーションビルド時、ソースファイルを再コンパイルせずに複数の実行ファイルへリンクできる
- リンク実行時にスタティックライブラリファイル名のみを与える
  -> リンクコマンドラインが簡潔になる

### 欠点
- 同じオブジェクトファイルが別のプログラム内部にそれぞれ含まれるためディスク容量を消費する
- 異なるプログラムでも内部で同じモジュールを使用する実行ファイルを複数同時に実行すると、
  それぞれが仮想メモリ内にオブジェクトモジュールのコピーを持つことになり、
  仮想メモリ消費増大につながる
- スタティックライブラリ内部のオブジェクトモジュールを変更した場合、
  リンクしている全ての実行ファイルに対して再リンクが必要になる

### ファイル名
- `libアーカイブ名.a`とする

### 作成方法
```
$ ar options libarchive.a object-file.o ...
```

#### 処理の種類
- `r` - replace
  - アーカイブへオブジェクトファイルを追加し、
    同名のオブジェクトファイルがある場合は上書きする
- `t` - table of contents
  - アーカイブの内容を一覧表示する
- `d` - delete
  - 指定したオブジェクトファイルをアーカイブから削除する

### 実行ファイルへのリンク方法
- リンク時のコマンドラインにスタティックライブラリ名を指定する

```
$ gcc -g -c prog.c # プログラムをコンパイル
$ gcc -g -o prog prog.o libarchive.a
```

- ファイル名から`lib`と`.a`を削除したライブラリ名を`-l`で指定する
```
# リンカが標準で検索するディレクトリへスタティックライブラリが置かれている場合
# (/usr/libなど)
$ gcc -g -o prog prog.o -larchive

# リンカが標準で検索するディレクトリへスタティックライブラリが置かれていない場合
$ gcc -g -o prog prog.o -Ldirname -larchive
```

## 参照
- Linuxプログラミングインターフェース 2章 / 41章