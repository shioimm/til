# 操作
## CUI操作
#### SSH鍵の生成
- EC2インスタンスにSSHログインするための鍵を作成する

```
$ export KEY_NAME="キー名"
$ aws ec2 create-key-pair --key-name ${KEY_NAME} --query 'KeyMaterial' --output text > ${KEY_NAME}.pem --profile プロファイル名 --region リージョン名
$ mv キー名.pem ~/.ssh/
$ chmod 400 ~/.ssh/キー名.pem
```

#### CDKによるCloudformationスタックのデプロイ
- CDKの設定情報に沿ってVPC、EC2などがAWS上に展開される
```
$ cdk deploy -c key_name="キー名" --profile プロファイル名 --region リージョン名
```
- 起動に成功すると`InstancePublicIp`として起動したインスタンスのパブリックIPアドレスが表示される

#### SSHログイン
```
$ ssh -i ~/.ssh/キー名.pem ec2-user@<IP address>
```

#### Cloudformationスタックを削除
```
$ cdk destroy --profile プロファイル名 --region リージョン名
```

## GUI操作
### EC2インスタンス作成
1. AMIの選択
    - Amazon Machine Image - コンピューティング環境のテンプレート(OS)
2. インスタンスタイプの選択
3. インスタンスの詳細の設定
4. ストレージの追加
    - EBSのボリュームの種類・サイズ
    - EBS - EC2で使用する外部ストレージである
5. タグの追加
    - インスタンスを分類するために使用する
6. セキュリティグループの設定
    - セキュリティグループ - ファイアウォールの設定
7. 確認
8. キーペアのダウンロード
    - キーペア - サーバーに入るための鍵-鍵穴
9. 作成したインスタンスに名前をつける

## コンソール
### パブリックアドレスの確認
- EC2 > インスタンス > [該当インスタンスを選択] > 説明
  - パブリックDNS(IPv4)
  - IPv4 パブリックIP
  - IPv6 IP
  - Elastic IP

## 参照
- [Amazon EC2](https://aws.amazon.com/jp/ec2/?nc2=h_ql_prod_fs_ec2)
- AWSをはじめよう　～AWSによる環境構築を1から10まで～
- サーバ・インフラエンジニアの基本がこれ一冊でしっかり身につく本 9.3
- [4. Hands-on #1: 初めてのEC2インスタンスを起動する](https://tomomano.github.io/learn-aws-by-coding/#sec_first_ec2)
