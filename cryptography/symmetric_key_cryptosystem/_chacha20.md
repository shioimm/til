# ChaCha20
- ストリーム暗号化方式
- 2014年~ GoogleChromeで採用
- モバイル環境や組み込み環境ではAESよりも高速
- 256ビットの秘密鍵と96ビットのnonceを元に512ビットずつの疑似乱数を生成し、
  生成した乱数と平文の排他的論理和をとって暗号文にする

#### ChaCha20の擬似ランダム関数
1. 256ビットの秘密鍵k、96ビットのnonce n、32ビットのカウンタb、128ビットの初期定数cを用意 (合計512ビット)
2. 1を32ビットずつ16分割し、それを4 * 4の正方形に並べる (内部状態の初期値)
3. 2を1/4ラウンド関数QRによってかき回す処理を10回行う
4. 3に元の初期値に加算して乱数とする

## 参照
- 図解即戦力　暗号と認証のしくみと理論がこれ1冊でしっかりわかる教科書
