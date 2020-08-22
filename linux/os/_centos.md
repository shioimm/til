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
