# キーペアの再発行
- EC2 > ネットワーク&セキュリティ > キーペア > キーペアを作成
  - 作成したキーペアは自動的にダウンロードされる
  - ダウンロードされたキーペアを`~/.ssh/`以下に移動し、権限を変更

```
$ mv ~/Downloads/キーペア名.pem ~/.ssh/
$ chmod 400 ~/.ssh/xxxxx.pem
```

- キーペアの公開鍵を取得
```
$ ssh-keygen -y -f ~/.ssh/キーペア名.pem
```

- EC2 > インスタンス > [インスタンスを選択] > [イメージ] > [イメージの作成]
  - 名前をつけてAMIを作成
- AMI >[AMIを選択] > [起動] > インスタンスを再作成
  - 作り直したキーペアを選択する
- SSHで接続確認(再接続につきIPアドレスが変更されているので注意する)

```
$ ssh ユーザー名(AMIによりec2-userもしくはubuntu)@パブリックIPアドレス -i ~/.ssh/キーペア名.pem
```

- 接続が確認できたら古いインスタンスを削除
  - EC2 > インスタンス > [インスタンスを選択] > [インスタンスの状態] > 終了
  - 作成したイメージを削除する場合は
    - AMI > [AMIを選択] > [登録解除]
    - スナップショット > [スナップショットを選択] > [削除]

### 以下の方法だと新規作成したキーペアをうまく設定できずPermission deniedになった
- EC2 > インスタンス > [インスタンスを選択] > [インスタンスの状態] > 停止
- EC2 > インスタンス > [インスタンスを選択] > [インスタンスの設定] > ユーザーデータの表示・変更

```
# (ユーザーデータ:)

Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [users-groups, once]
users:
  - name: ユーザー名(AMIによりec2-userもしくはubuntu)
    ssh-authorized-keys:
    - キーペアの公開鍵(ssh-rsaから最後まで)
```

- SSHで接続確認(再接続につきIPアドレスが変更されているので注意する)

```
$ ssh ユーザー名(AMIによりec2-userもしくはubuntu)@パブリックIPアドレス -i ~/.ssh/キーペア名.pem
```

- 接続が確認できたらインスタンスを停止し、ユーザーデータを削除し、インスタンスを再起動

## 参照
- [最初の起動後に SSH キーペアを紛失した場合、Amazon EC2 インスタンスに接続するにはどうすればよいですか?](https://aws.amazon.com/jp/premiumsupport/knowledge-center/user-data-replace-key-pair-ec2/)

