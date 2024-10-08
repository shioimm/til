# 疑似端末
- 双方向IPCチャネルの機能を備える仮想的なデバイス
- 疑似端末を使用することによって任意の2プロセスが通信を行うことができる
  - 2プロセスがマスターデバイス・スレーブデバイスをそれぞれオープンし、
    疑似端末を介して双方向にデータを送受信する
- チャネルの片方の口は端末へ接続するプログラム、
  もう片方の口は端末上での動作を想定したプログラム(端末指向プログラム)
  - 端末指向プログラム - ユーザー入力を端末へ書き込み、端末からの出力を読み取る

### 疑似端末ペア
- 疑似端末マスターデバイス / 疑似端末スレーブデバイスの組み
- マスターデバイスをオープンしたプログラムからスレーブデバイスに接続した端末指向プログラムを操作できる
- スレーブデバイスは通常の端末同様に動作する
- マスターデバイスに入力したデータは通常の端末のキーボードへの入力のようにスレーブデバイスが処理する

### 双方向パイプとの違い
- スレーブデバイスが端末デバイスとしての機能を持つ点
  - スレーブデバイスは自身への入力を本来の端末へのキーボード入力と同様に解釈する

### 双方向パイプとの共通点
- 容量に制限があり、制限に達した場合書き込みはブロックされる
  - 他方がデータを読み取り、空き容量が生まれると書き込み可能になる

### 利用例
- リモートホスト上のsshd(ドライバプログラム)とログインシェル(端末指向プログラム)
- 端末エミュレータ
- `script(1)`
- 長時間実行プログラムの出力監視

### 端末属性とウィンドウサイズ
- マスターデバイスとスレーブデバイスは端末属性(`termios`構造体)とウィンドウサイズ(`winsize`構造体)を共有する

## 疑似端末ペアの確立
- 疑似端末マスターデバイスをオープンするプロセスが
  他プロセスへスレーブデバイス名を通知することによってペアが確立する
  - 通知方法はファイルへの書き込み、IPC、`fork(2)`など

### `fork(2)`でスレーブデバイス名を通知する例
1. ドライバプログラムが疑似端末マスターデバイスをオープン
2. ドライバプログラムは`fork(2)`を実行し、子プロセスを作成
3. 子プロセスは`setsid(2)`を実行し、新規セッションを開始し、制御端末を手放す
4. 子プロセスは疑似端末マスターデバイスに対応する疑似端末スレーブデバイスをオープン
    - 疑似端末スレーブデバイスが子プロセスの制御端末となる
5. 子プロセスは`dup(2)`を実行し、スレーブデバイスのファイルディスクリプタを標準入出力へ複製する
6. 子プロセスは`exec(2)`を実行し疑似端末スレーブデバイスへ接続した端末指向プログラムを実行する

## 疑似端末の使用
- 疑似端末ペアの確立以降、
  - ドライバプログラムがマスターデバイスへ書き込んだデータは
    全てスレーブデバイス上で動作する端末指向プログラムへの入力となる
  - 端末指向プログラムがスレーブデバイスへ書き込んだデータは
    全てマスターデバイス上で動作するドライバプログラムへの入力となる

## 擬似端末IO
#### 擬似端末マスターデバイスに対応するファイルディスクリプタが全てクローズされた場合
- スレーブデバイスに制御プロセスが存在する場合、`SIGHUP`を送信する
- スレーブデバイスに対して`read(2)`した場合、EOFを返す
- スレーブデバイスに対して`write(2)`した場合、EIOエラーになる

#### 擬似端末スレーブデバイスに対応するファイルディスクリプタが全てクローズされた場合
- マスターデバイスに対して`read(2)`した場合、EIOエラーになる
- マスターデバイスに対して`write(2)`した場合、スレーブデバイスの入力キューに空きができれば書き込む

### パケットモード
- スレーブデバイスに対して特定のソフトウェアフロー制御を実行した際にマスターデバイスが検知する機能
  - 入力・出力キューがフラッシュされた際
  - 端末出力が停止・再開された際
  - フロー制御が有効化・無効化された際
- マスターデバイスに対して`ioctl(2)`に`TIOCPKT`を実行することでパケットモードを指定する
- パケットモードではマスターデバイスからデータと読み取ると2種類のデータを得られる
  - 1バイトの制御バイト(数値0以外 / スレーブデバイス上で発生した変化を表す)
  - 先頭にNULLバイトを持つ、スレーブデバイスに入力されたデータ
- パケットモードの擬似端末の状態が変化すると、マスターデバイス上の`select(2)`は例外条件を検出する
  - `poll(2)`は`revents`フィールドに`POLLPRI`フラグをセットする

## 高度な機能
- パケットモード
  - マスター側がスレーブ側の状態変化を感知できるようになる
- リモートモード
  - スレーブ側をリモートモードに設定する
  - スレーブはマスターから受け取ったデータの処理を行わない
- ウィンドウサイズの変更
- シグナル生起
  - マスターからスレーブのプロセスグループへシグナルを送る

## 参照
- Linuxプログラミングインターフェース 64章
