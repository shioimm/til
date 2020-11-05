# CircleCI CLI
- [CircleCI-Public/circleci-cli](https://github.com/CircleCI-Public/circleci-cli)

## Get Started
```
$ curl -fLSs https://raw.githubusercontent.com/CircleCI-Public/circleci-cli/master/install.sh | bash
```

## アップデートのチェック
```
$ circleci update check
$ circleci update install
```

## セットアップ
```
$ circleci setup
```
- [Personal API Token tab](https://app.circleci.com/settings/user/tokens)で発行したトークンを設定する

## 設定ファイル`.circleci/config.yml`のバリデーションチェック
```
$ circleci config validate
```

## ローカルでのジョブ実行
```
$ circleci local execute
```
