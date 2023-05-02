# xxd(1)
- ファイルや標準入力から受け取った内容を16進数でダンプする
- 16進数ダンプから元のデータを復元する

```
# ファイルを16進数でダンプし、DUMP_FILEに出力する
$ xxd ORIG_FILE DUMP_FILE

# DUMP_FILEの内容を復元してNEW_FILEに出力する
$ xxd -r DUMP_FILE NEW_FILE
```
