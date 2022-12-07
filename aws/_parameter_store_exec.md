# parameter-store-exec
- AWSのパラメータストアに保存した機密情報を環境変数として展開し、プログラムを実行するツール
- parameter-store-execコマンド実行時、
  パラメータストアのパスは環境変数`PARAMETER_STORE_EXEC_PATH`としてプログラムに読み込まれる

## 参考
- [AWS Systems Manager Parameter Store](http://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-paramstore.html)
