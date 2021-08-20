# AWS CLI
#### インストール
- [Installing, updating, and uninstalling the AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

#### 設定
- [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)
- [Understanding and getting your AWS credentials](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html)
- [15.3. AWS CLI のインストール](https://tomomano.github.io/learn-aws-by-coding/#aws_cli_install)
- [15.2. AWS のシークレットキーの作成](https://tomomano.github.io/learn-aws-by-coding/#aws_secrets)

```
$ aws configure

# AWS Access Key ID
# AWS Secret Access Key
# Default region name = リージョン名(ap-northeast-1: 東京リージョン)
```

- `~/.aws/credentials` - 認証鍵の情報
- `~/.aws/config` - AWS CLI の設定
- 環境変数`AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_DEFAULT_REGION`に指定された値の方が優先される

#### 操作
- [AWS CLI での高レベル (S3) コマンドの使用](https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/cli-services-s3-commands.html)
- 実行時に`--profile`オプション、`--region`オプションをつける

```
$ aws s3 mb "s3://${bucketName}" --profile sample-aws-user --region ap-northeast-1
```
