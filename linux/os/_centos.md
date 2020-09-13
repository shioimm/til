# CentOS
- 参照: [CentOS](https://www.centos.org/)

## TL;DR
- Red Hat Enterprise Linux(RHEL)から派生したLinuxディストリビューション
- RHELとの機能的な互換性があり、安定性、予測可能性、管理可能性、再現性を特徴とする

## Firewalld
- CentOSで使用されているファイアウォール
```
# ファイアウォールの設定を確認
$ sudo firewall-cmd --list-all

# ファイアウォールの設定を変更
# publicゾーンにおいて、httpを通信を許可するポートとして追加し、設定を永続化
$ sudo firewall-cmd --zone=public --add-service=http --permanent

# publicゾーンにおいて、httpを通信を許可するポートとして削除し、設定を永続化
$ sudo firewall-cmd --zone=public --remove-service=http --permanent

# ファイアウォールの設定をリロード
$ sudo firewall-cmd --reload
```

## 事例
### systemにRubyをインストールしたい
- 参照: [CentOS7にRubyをインストール](https://qiita.com/jjjjjj/items/75a946fe84ca40b5d9a9)
```
$ sudo yum -y install git bzip2 gcc gcc-c++ openssl-devel readline-devel zlib-devel

# どのユーザーでも使用できるように/usr/local以下にインストールする
$ sudo git clone https://github.com/rbenv/rbenv.git /usr/local/rbenv
$ sudo git clone https://github.com/rbenv/ruby-build.git /usr/local/rbenv/plugins/ruby-build

$ sudo su
# vim /etc/profile.d/rbenv.sh↲
```

```
# /usr/local配下のrbenvにパスを通す
export RBENV_ROOT="/usr/local/rbenv"
export PATH="${RBENV_ROOT}/bin:${PATH}"
eval "$(rbenv init --no-rehash -)"
```

```
# source /etc/profile.d/rbenv.sh
# visudo
```

```
Defaults env_keep += "RBENV_ROOT"
Defaults secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/rbenv/bin:/usr/local/rbenv/shims
```

```
$ sudo rbenv install x.x.x
$ sudo rbenv global x.x.x
$ sudo rbenv rehash
$ sudo ruby -v     # ruby x.x.x
$ sudo which ruby  # /usr/local/rbenv/shims/ruby
$ sudo which rbenv # /usr/local/rbenv/bin/rbenv
```

## サーバー証明書発行
```
# 秘密鍵生成
$ cd /etc/pki/tls/certs
$ sudo make xxx-server.key # 任意のパスフレーズを2回入力

# CSR作成
$ sudo make xxx-server.csr # パスフレーズを入力

# 作成したCSRの確認
$ sudo openssl req -utf8 -in xxx-server.csr -text

# パスフレーズの削除
$ sudo openssl rsa -in xxx-server.key -out xxx-server.nopass.key
$ sudo chmod 400 xxx-server.nopass.key
```
