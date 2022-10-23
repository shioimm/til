# AWS CLI
- AWS Access Key ID - AWSアカウントとIAMユーザーを一位に特定する情報
- AWS Secret Access Key - アクセスキーIDのパスワード
- Default region name - CLIの操作対象のリージョン (ap-northeast-1: 東京リージョン)
- Default output format - 出力形式 (デフォルト: JSON)

## Usage
#### インストール・設定
- [Installing, updating, and uninstalling the AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
- [Understanding and getting your AWS credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html)
- [15.3. AWS CLI のインストール](https://tomomano.github.io/learn-aws-by-coding/#aws_cli_install)
- [15.2. AWS のシークレットキーの作成](https://tomomano.github.io/learn-aws-by-coding/#aws_secrets)

```
$ aws configure

# AWS Access Key ID
# AWS Secret Access Key
# Default region name
# Default output format
```

- `~/.aws/credentials` - 認証鍵の情報
- `~/.aws/config` - AWS CLI の設定
- 環境変数`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_DEFAULT_REGION`に指定された値の方が優先される

#### 操作
```
# $ aws <ServiceName> <Command> --<Option> <Params>

$ aws s3 mb "s3://${bucketName}" --profile sample-aws-user --region ap-northeast-1
```

- 実行時に`--profile`オプション、`--region`オプションをつける
- [AWS CLI での高レベル (S3) コマンドの使用](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-services-s3-commands.html)
