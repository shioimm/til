# VRRP
- Virtual Router Redundancy Protocol
- ルータの冗長性を確保するためのプロトコル
  - 複数のルータを一つの仮想ルータグループとして扱い、そのうち一つをマスタールータとする
  - 平時はマスタールータをデフォルトルータとする
  - マスタールータが故障した際は他のルータ (バックアップルータ) に切り替わって通信を行う

## 仕組み
1. マスタールータは定期的にVRRPパケットをマルチキャストしている
2. バックアップルータが3回分のVRRPパケットを受け取れなかった際、
   マスタールータに障害が発生したと判断しバックアップルータの一つがデフォルトルータとなる
    - バックアップルータ群は切り替わる優先順位を決めて運用される
3. マスタールータからバックアップルータに切り替わる際、MACアドレスとIPアドレスが引き継がれる
    - バックアップルータは自身のNICのMACアドレスを使用せず、
      VRRP専用の仮想ルータMACアドレスを使用する
    - 仮想ルータMACアドレスにはマスタールータのMACアドレスを設定しておく
    - バックアップルータは自身のNICにデフォルトルートとは異なるIPアドレスを設定し、
      デフォルトルートには仮想IPアドレスを設定する
4. バックアップルータは自分へパケットを誘導するためにGARPパケットを流す
    - スイッチングハブのMACアドレステーブルを更新させる

## 参照
- マスタリングTCP/IP 入門編
