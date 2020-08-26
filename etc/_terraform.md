# Terraform
- 参照: [Terraform](https://www.terraform.io/)
- 参照: [インフラの構成管理を自動化するTerraform入門](https://thinkit.co.jp/story/2015/07/14/6212)

## TL;DR
- インフラ構築・変更・バージョン管理を安全かつ効率的に行うためのツール
- リソース単位で様々なクラウドの基盤を扱う
- 設定をコードで管理し、コマンドラインで実行する

### 実行
- リソース情報をコードとして記述する
- インフラの構築・変更・破棄をコマンドラインで行う
  - 設定反映前にドライラン(terraform plan)を実行して確認後、設定を適用(terraform apply)する
  - IPアドレスや仮想サーバに関する情報を確認する(terraform show)
  - コマンド実行時、リソースで指定されたインフラごとにterraform-providerが呼び出され、APIを通した自動処理を行う

### キーワード
- Infrastructure as Code
  - インフラの状態をテキスト上にコードとして管理することにより、
    設計をバージョン化し、共有したり再利用したりする
- Execution Plans
  - terraform planのステップを持つことにより、
    terraform apply呼び出し時の挙動を確認することができる
- Resource Graph
  - すべてのリソースのグラフを構築することにより、
    リソースを可能な限り効率的に構築し、その依存関係を把握することができる
- Change Automation
  - Execution PlansとExecution Plansにより、どんな変更をどの順番で行うかを正確に把握することができる
