# Terraform
- インフラの構成をソースコードとして管理し、CLIで実行するツール
- コマンド実行時、リソースで指定されたインフラごとにterraform-providerが呼び出され、APIを通して処理を行う

## 実行
1. リソース情報をterraformファイルに記述
2. `$ terraform init`で初期化
    - 対象クラウドへの認証処理を実行
    - 依存ファイルを取得
    - リソースなどメタ情報を含むファイル (state ファイル) の生成
3. `$ terraform plan`
    - 使用しているアカウントの権限の確認
    - terraformファイルの文法のチェック
    - 最終的に生成されるリソースのチェック
4. `$ terraform apply`
    - リソースを生成

## 基本概念
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

## 参照
- [Terraform](https://www.terraform.io/)
- [インフラの構成管理を自動化するTerraform入門](https://thinkit.co.jp/story/2015/07/14/6212)
