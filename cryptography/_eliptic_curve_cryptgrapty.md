# 楕円曲線暗号 (Eliptic Curve Cryptgraphy)
- 楕円曲線を利用した暗号技術全般
- 公開鍵暗号、鍵共有・署名などに用いられる
- RSA暗号に比べて短い鍵長 (高速) で同等の安全性を提供できる

### ECDH鍵共有
- 楕円曲線を用いたDH鍵共有

#### ECDHP
- `(g, p, (g **a) mpd p, (g ** b) mod p)が与えられたときg ** (a * b) mod pを求めよ`

#### 動作フロー
1. Alice、BobはあらかじめECDHPを解くのが困難な楕円曲線と点Pを決めておく
2. Aliceは自分だけの秘密の値aを決める
3. Bobは自分だけの秘密の値bを決める
4. Aliceは`A = aP`を計算してBobに渡す
5. Bobは`B = bP`を計算してAliceに渡す
6. AliceはBから`s = aB`を計算する
7. BobはAから`s' = bA`を計算する
8. `aB = a(bP) = abP`、`bA = b(aP) = abP`は等しいため`s = s'`となる
9. Alice、Bobは以降`s = s'`を秘密鍵として用いる

## 参照
- 図解即戦力　暗号と認証のしくみと理論がこれ1冊でしっかりわかる教科書
