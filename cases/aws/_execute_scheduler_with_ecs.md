# ECSでスケジューラタスクを実行する際のTODO (e.g.)
1. CloudFormationのテンプレート.jsonを作成 (`Type: AWS::ECS::TaskDefinition`)
2. `$ aws cloudformation deploy --stack-name <スタック名> --template-file path/to/<テンプレート.json> --no-execute-changeset --profile <Profile名>`
3. CloudFormationから変更セットを実行
    - CloudFormation
    -> スタック
    -> `<スタック名>`
    -> 変更セット
    -> `awscli-cloudformation-package-deploy-*********` (名前)
    -> 変更内容を確認し、「変更セットを実行」ボタン押下
4. CloudWatchからスタックの実行を確認
    - CloudWatch
    -> イベント
    -> ルール
    -> 「CloudWatchEvent に戻る」ボタン押下
    -> `<スケジューラ名>`
    -> 「アクション」から有効化・無効化可能

#### パラメータのみ変更の場合
- パラメータ (`Parameters`以下) のみの変更の場合は`--parameter-overrides`オプションを追加

```
$ aws cloudformation deploy --stack-name <スタック名> --template-file path/to/<テンプレート.json> --no-execute-changeset --parameter-overrides <パラメータ名>='<パラメータの内容>' --profile <プロフィール名>
```

#### ワンショットタスクを今すぐ実行
1. `タスクの実行定義.json`を用意
2. `$ aws ecs run-task --cli-input-json file://path/to/<タスクの実行定義.json`
