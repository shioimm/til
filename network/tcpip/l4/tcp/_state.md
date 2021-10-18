# TCPの状態
- LISTEN
  - ピアTCPからの接続要求を待っている
- SYN-SENT
  - アプリケーションがアクティブオープンを実行し、TCPがSYNを送信し、
    コネクションを完了するべくピアTCPからのSYNに対する応答を待っている
- SYN-RECV
  - LISTEN状態だったTCPがSYNを受信し、SYN/ACKを返し、
    コネクションを完了するべくピアTCPからのACKを待っている
-  ESTABLISHED
  - ピアTCPへのコネクションが確立された
- FIN-WAIT1 (アクティブクローズ) -> FIN-WAIT2 / CLOSING
  - アプリケーションがコネクションをアクティブクローズし、自TCPはピアTCPへFINを送信し、ACKを待っている
- FIN-WAIT2 (アクティブクローズ) -> TIME-WAIT
  - FIN-WAIT1だったTCPがACKを受信した
- CLOSING (アクティブクローズ) -> TIME-WAIT↲
  - FIN-WAIT1だったTCPのピアTCPがアクティブクローズし、自TCPがピアTCPからFINを受信した
- TIME-WAIT (アクティブクローズ)
  - TCPがアクティブクローズを実行し、ピアTCPがパッシブクローズを実行し、自TCPがピアTCPからFINを受信した
  - 規定時間経過後にコネクションはクローズされ、使用していたカーネルリソースが解放される
    - 規定時間: 2MSL(最長セグメント寿命)(Linuxは1MSLが30秒)
    - 規定時間中に同じポートを別ソケットにバインドしようとするとEADDRINUSEが発生する
    - SO-REUSEADDRオプションはTIME-WAITの信頼性を維持しつつEADDRINUSEを回避する
- CLOSE-WAIT (パッシブクローズ) -> LAST-ACK
  - ピアアプリケーションがアクティブクローズを実行し、自TCPがピアTCPからFINを受信した
- LAST-ACK (パッシブクローズ)
  - アプリケーションがパッシブクローズを実行し、CLOSE-WAITだったTCPがFINを送信し、
    ピアTCPからのACKを待っている
  - ACKを受信するとコネクションはクローズされ、使用していたカーネルリソースが解放される

## 参照
- Linuxプログラミングインターフェース 58章 / 61章
