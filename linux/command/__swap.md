# スワッピング
## スワップの発生を観測
```
$ sar -W 1(間隔秒)
```

## システムのスワップ領域を表示
```
$ swapon --show

# Swap: - スワップ領域についての表示
```

```
# スワップ領域の使用量の推移
$ sar -S
```

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
