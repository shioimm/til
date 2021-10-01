# インストール
- ソースコードからビルドしてインストールする
- OSのパッケージシステムからパッケージをインストールする
- nginx.org提供のバイナリパッケージをインストールする

### CentOS
- 参照: [RHEL/CentOS](http://nginx.org/en/linux_packages.html#RHEL-CentOS)

(1) `etc/yum.repos.d/`にリポジトリファイル`/etc/yum.repos.d/nginx.repo`を追加
```
[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=0
enabled=1
```

(2) `$ sudo yum install -y nginx` - インストール
(3) `$ sudo systemctl start nginx` - 開始
(4) `$ sudo systemctl status nginx` - ステータスの確認
(5) `$ sudo systemctl enable nginx` - デーモン化
(6) `$ firewall-cmd --list-services --zone=public --permanent` - FW許可サービスの確認
(7) `$ firewall-cmd --add-service=http --zone=public --permanent` - FWを許可
(8) `$ firewall-cmd --reload` - FWのリロード

## 参照
- [Installing nginx](https://nginx.org/en/docs/install.html)
- [nginx連載2回目: nginxの紹介](https://heartbeats.jp/hbblog/2012/01/nginx01.html)
