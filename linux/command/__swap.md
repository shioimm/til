## スワップ領域の確保
```
$ mkswap /swapfile # スワップ領域の確保
$ swapon /swapfile # 確保した領域を使用
```

```
# /etc/fstab
# 次回ブート時にスワップ領域を有効化させる

/swapfile swap swap defaults 0 0
```
