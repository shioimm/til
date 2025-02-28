# pfctl (BSD系)

- パケットフィルタの設定

```
$ sudo pfctl -s all
```

```
# ALTQ = トラフィック制御 (キューイング) 用拡張機能
No ALTQ support in kernel ALTQ related functions disabled (カーネルにALTQが有効になっていない)

TRANSLATION RULES:
nat-anchor NATに関する設定
rdr-anchor リダイレクトに関する設定

FILTER RULES:
scrub-anchor パケットの再構築に関する設定
anchor アンカーに関する設定

DUMMYNET RULES:
dummynet-anchor 帯域制御に関する設定

INFO:
Status: pf の有効 / 無効化
```
