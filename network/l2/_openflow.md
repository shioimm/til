# OpenFlow
- SDN: Software-Defined Networkingの一方式
- 従来一台の物理的なネットワーク機器の内部に同居していた経路制御の機能とデータ転送の機能を
  OpenFlowコントローラ (経路制御) と複数のOpenFlowスイッチ (データ転送) に分離し、
  OpenFlowコントローラによってOpenFlowスイッチの設定や振る舞いを一括して管理する
  - 経路制御の機能はOpenFlowコントローラのControl Planeが担う
  - データ転送の機能はOpenFlowスイッチのData Planeが担う

## 動作フロー
- 各OpenFlowスイッチの動作を記述したフローテーブルを作成
- OpenFlowコントローラはフローテーブルをOpenFlowプロトコルによって配送
- 各OpenFlowスイッチはフローテーブルに基づいてデータの転送や破棄、宛先の書き換えなどを実施

## 参照
- [OpenFlowとは](https://www.infraexpert.com/study/sdn02.html)
- [OpenFlow](https://e-words.jp/w/OpenFlow.html)
