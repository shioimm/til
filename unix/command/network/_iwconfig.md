# iwconfig(1)
- 無線LANインターフェースの詳細表示・設定を行う

```
# ホストの無線LANインターフェースの詳細表示
$ iwconfig

# モードの変更
$ sudo iwconfig en0 mode monitor

# チャンネルの変更
$ sudo iwconfig en0 channel 3

# 変更を有効化する
$ sudo iwconfig en0 up
```
