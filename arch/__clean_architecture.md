# Clean Architecture 達人に学ぶソフトウェアの構造と設計 メモ
- アーキテクチャの関心事 - コンポーネントの分離、データ管理、機能

## プログラミングパラダイム (P49~)

| 種類   | 制限された機能                          | 導入された概念         | 発展的な考え方           |
| -      | -                                       | -                      | -                        |
| 構造化 | 直接的な制御の移行 (goto文の使用)       | 機能分割、テスト可能性 | -                        |
| OOP    | 間接的な制御の移行 (関数ポインタの使用) | 依存関係の方向の制御   | プラグインアーキテクチャ |
| 関数型 | 代入 (可変変数の使用)                   | 可変性の分離           | イベントソーシング       |

- アーキテクチャの関心事: コンポーネントの分離、データ管理、機能
  - コンポーネントの分離 - アーキテクチャの境界を越えるための仕組みとしてポリモーフィズムが利用される
  - データ管理 - データの配置やアクセスに規律を課すために関数型プログラミングが利用される
  - 機能 - モジュールのアルゴリズムの基盤として構造化プログラミングが利用される

## モジュールレベルの設計 (P77~)
- SOLID原則の目的 - 変更に強い、理解しやすい、再利用性の高いモジュールレベルのソフトウェア構造の構築

### 単一責任の原則 (SRP)
- モジュールはたった一つの理由、タイミングによって変更されるべきである
  (= 複数の理由、タイミングによって変更されるモジュールは複数のモジュールへ分割するべきである)
- 関数・クラスレベル   -> 単一責任の原則
- コンポーネントレベル -> 閉鎖性共通の原則
- アーキテクチャレベル -> (アーキテクチャの境界を作るための) 変更の軸

### オープン・クローズドの原則 (OCP)
- モジュールは拡張に対しては開き、修正に対しては閉じていなければならない
  (= モジュールの振る舞いは既存の成果物を変更せず拡張できるようにすべきである)
- モジュールの依存関係は階層構造とし、上位レベルのモジュールは下位レベルのモジュールの変更の影響を受けない

### リスコフの置換原則 (LSP)
- S型のオブジェクトをT型のオブジェクトに置き換えても動作が変わらない場合、SはTの派生型である
  (= モジュールは定義されたインターフェースとそのインターフェースの実装の置換可能性に依存するべきである)

### インターフェース分離の原則 (ISP)
- モジュールが依存するインターフェースにはモジュールが必要とする実装のみが含まれているべきである
  (= インターフェースはモジュールが必要とする実装ごとに分離されているべきである)

### 依存関係逆転の原則 (DIP)
- モジュールは具象的な実装ではなく安定した抽象インターフェース (= 変化しにくい要素) にのみ依存するべきである
  - モジュールは具象を名指しで参照するべきではない
  - モジュールは具象クラスを継承するべきではない
  - モジュールは具象関数をオーバーライドするべきではない

## コンポーネントレベルの設計 (P107~)
- コンポーネント - デプロイ単位となるソフトウェア (ライブラリ、バイナリファイルetc)

### コンポーネントの凝集性に関する原則
- 再利用・リリース等価の原則と閉鎖性共通の原則はコンポーネントを大きくする方向へ作用する
- 全利用性の原則はコンポーネントを小さくする方向へ作用する
- 全利用性の原則を軽視すると             -> 不要なリリース作業が増加する
- 再利用・リリース等価の原則を軽視すると -> 再利用性が低下する
- 閉鎖性共通の原則を軽視すると           -> 変更すべきコンポーネントが増加する

#### 再利用・リリース等価の原則 (REP)
- 再利用の単位とリリースの単位は等価になるべきである
  (再利用性のためのグループ化)
  - コンポーネントを構成するモジュール群は凝集性のあるまとまりでなければならない
  - コンポーネントを構成するモジュール群はまとめて同時にリリース可能でなければならない

#### 閉鎖性共通の原則 (CCP)
- 同じ理由、同じタイミングで変更されるモジュール同士を一つのコンポーネントにまとめ、
  変更の理由やタイミングが異なるモジュール同士は別のコンポーネントに分けるべきである
  (保守性のためのグループ化)
- 単一責任の原則をコンポーネント向けに言い直したもの (同じ理由、タイミングで変更するものはひとまとめにする)

#### 全利用性の原則 (CRP)
- コンポーネントのユーザーに対して、実際に使わないモジュールへの依存を強要してはいけない
  (不要なリリース作業を減らすための分割)
- インターフェース分離の原則を一般化したもの (不要なものには依存しない)

### コンポーネントの結合に関する原則 (P125~)
#### 非循環依存関係の原則 (ADP)
- コンポーネント同士の依存関係は一方向になっている (循環依存しない) べきである
  - コンポーネント同士の独立性を高め、一方の変更が他方に影響を及ぼさないようにするため

#### 安定依存の原則 (SDP)
- コンポーネントは自らよりも安定度の高いコンポーネントへ依存するべきである
  - 独立コンポーネント - 他のコンポーネントに依存せず、他のコンポーネントから依存されるコンポーネント
  - 従属コンポーネント - 他のコンポーネントに依存し、他のコンポーネントから依存されないコンポーネント

```
# ファン・イン  (依存入力数: 自コンポーネントに含まれるクラスに依存する外部コンポーネントのクラス数)
# ファン・アウト(依存出力数: 自コンポーネントに含まれるクラスが依存する外部コンポーネントのクラス数)

# Iが1に近いほど安定度が低い
安定度I = ファン・アウト / (ファン・イン + ファン・アウト)
```

- 安定度の高いコンポーネントsから安定度の低いコンポーネントfへの依存を取り除くためには
  s -> fの間にインターフェースとなるコンポーネントsfを増やし、
  s -> sf <- f となるような依存関係をつくる (sfは安定度が高い状態となる: 依存関係逆転の法則)

#### 安定度・抽象度等価の原則 (SAP)
- コンポーネントの抽象度はその安定度と同程度であるべきである
- 抽象クラスとインターフェースを多く持つコンポーネントは拡張しづらい (抽象度が高い)

```
# Nc (コンポーネント内のクラスの総数)
# Na (コンポーネント内の抽象クラスとインターフェースの総数)

# Aが1に近いほど抽象度が高い
抽象度A = Na / Nc
```

```
# 主系列 - 安定度・抽象度がともに高い位置から安定度・抽象度がともに低い位置を結ぶ範囲
# 全てのコンポーネントは主系列に近い位置に置かれるべきである
#   変動性の低いコンポーネントは安定度が高く抽象度が高い状態に置く
#   変動性の高いコンポーネントは安定度が低く抽象度が低い状態に置く

# Dが1に近いほど主系列から離れている
主系列からの距離D = |安定度I + 抽象度A - 1|
```

## システムレベルの設計
- アーキテクチャの形状の目的はシステムのライフタイムコストを最小限に抑え、
  開発・デプロイ・運用・保守を容易にすることでプログラマの生産性を最大限にすること
  - ソフトウェアは方針 (高位) と詳細 (低位) に分類される
  - 方針と詳細は区分され、方針は詳細の決定を可能な限り遅延できるようにデザインされるべきである

### システムの切り離し方式 (P157~)
- 独立した運用・開発・デプロイを行うための選択肢
- 異なる理由で変更されるものを分離し、同じ理由で変更されるものをまとめる
- アプリケーションをレイヤ (水平方向) とユースケース (垂直方向) の2方向から各層ごとに分割する
- 時間とともに最適な切り離し構造が変化する可能性がある

### アーキテクチャの境界線 (P167~)
- アーキテクチャにとって重要なものとそうでないものの間に境界線を引く
- システムをコンポーネントに分割した際、ビジネスルールを表すコンポーネントが最も重要であり、
  それ以外のコンポーネントはプラグイン可能であるべきである
  - ビジネスルールを表すコンポーネントはそれ以外のコンポーネントに依存しない
  - ビジネスルールを表すコンポーネントはそれ以外のコンポーネントから依存される

#### アーキテクチャの境界線の分割単位 (P179~)

| コンポーネントの単位 | コンポーネント境界の通信 |
| -                    | -                        |
| ソースレベル         | 関数呼び出し             |
| デプロイレベル       | 関数呼び出し             |
| スレッドレベル       | スレッド間通信           |
| プロセスレベル       | プロセス間通信           |
| サービスレベル       | ネットワーク間通信       |

### クリーンアーキテクチャ (P199~)
- 関心事の分離を目的にビジネスルール層とインターフェース層が切り離されていること
- フレームワーク・UI・DB非依存であり、ビジネスルールが単体でテスト可能であること

| 抽象度 | 構成要素                             | コンポーネントの例                     |
| -      | -                                    | -                                      |
| 高     | ドメインのビジネスルール             | エンティティ                           |
| ↑      | アプリケーション固有のビジネスルール | ユースケース                           |
| ↓      | インターフェースアダプタ             | コントローラ・プレゼンタ・ゲートウェイ |
| 低     | フレームワーク・ドライバ             | Web・UI・DB                            |

#### エンティティ
- ドメイン固有のビジネスルールとドメイン固有のデータをカプセル化したコンポーネント

#### ユースケース
- アプリケーション固有のビジネスルール、エンティティへの参照と入出力をカプセル化したコンポーネント

#### インターフェースアダプタ (Presenter, View, Controller)
- ユースケースとドライバ間におけるデータの変換をカプセル化したコンポーネント

#### ドライバ / フレームワーク (IO, UI, DB)
- 詳細の実体となるコンポーネント

### クリーンアーキテクチャを実現するための考え方
#### Humble Objectパターン (P207~)
- 振る舞いを持つコンポーネントをテスト容易なコンポーネントとテスト不要なコンポーネントに分割するパターン
- アーキテクチャの境界を越える通信において境界の近くのコンポーネントをテスト容易にするために用いる

```
# 1. コンポーネントは自らよりも抽象度の高いコンポーネントからデータを受け取り、
#    フォーマットしたデータをテスト容易なコンポーネントに配置する
# 2. テスト不要なコンポーネントはテスト容易なコンポーネントから値を得て利用する

# e.g.
View (テスト不要) -> ViewModel (テスト容易) <- Presenter (テスト容易) <- ユースケース (テスト容易)
```

#### レイヤーと境界 (P215~)
- 完全な境界を構築する場合: 境界を構築・保守するためのコストが発生する
  (ポリモーフィックなインターフェース、入出力のデータ構造、双方のデプロイを独立させるための依存性管理)
- 一切の境界を構築しない場合: 新しいレイヤを追加するコストが増大する

#### mainコンポーネント (P223~)
- システムのエントリーポイントとして動作する最下位レベルの方針となる
- システムの実行時に初期状態や構成を設定し、外部リソースを集め、
  それらをアプリケーションの上位レベルの方針に渡すためのプラグインとして定義することができる
- アプリケーションの設定 (e.g. 開発、テスト、本番) ごとに複数のmainを用意することも考えられる

#### サービス
- アプリケーションを振る舞いによって分割し、別のプロセス・プラットフォームに切り離した単位
- サービス (振る舞いによる分割) ≠ コンポーネント (アーキテクチャの境界による分割)
- アーキテクチャの境界はサービスを横断する

## システムの詳細
- どのようなソフトウェア・データ形式・入出力方法を使用するかを決定する要素
  - DB
  - GUI
  - フレームワーク

## 参照
- Clean Architecture 達人に学ぶソフトウェアの構造と設計
