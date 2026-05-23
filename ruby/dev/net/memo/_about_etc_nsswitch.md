# `/etc/nsswitch.conf`
- どの情報源を使用してどの優先順位で名前解決を行うかを指定するための設定ファイル

```text
# e.g.
#   1. ローカルにあるファイル (/etc/hostsなどを参照) 、2. DNSサーバ (/etc/resolv.confを参照)、の順で名前解決を行う

hosts: files dns
```

```text
# /etc/nsswitch.conf
#
# Name Service Switch configuration
#

passwd:     files systemd        # ユーザーアカウント情報 (/etc/passwd 相当)
group:      files systemd        # グループ情報 (/etc/group 相当)
shadow:     files                # パスワードハッシュ (/etc/shadow 相当)
gshadow:    files                # グループのパスワード情報

hosts:      files dns myhostname # ホスト名からIPアドレスへの解決
networks:   files dns            # ネットワーク名からネットワークアドレスへの解決

protocols:  files                # プロトコル番号 (/etc/protocols 相当)
services:   files                # サービス名からポート番号への解決 (/etc/services 相当)
ethers:     files                # MACアドレスからホスト名の解決
rpc:        files                # RPCプログラム番号

netgroup:   files nis            # NISネットグループ
automount:  files nis            # 自動マウントのマップ情報
```

- files: ローカルファイルによる解決 (/etc/hosts、/etc/passwd など)
- dns: DNSサーバによるホスト名の解決 (/etc/resolv.confで指定)
- resolve: systemd-resolvedによるホスト名の解決
- systemd: systemdによるユーザー・グループ情報の解決
- myhostname: systemによる自ホスト名の解決 (localhostなど)
- nis: NISサーバによる解決
- ldap: LDAPディレクトリサーバによる解決
- db: /var/db/以下のBerkeley DBファイルによる解決
- mdns: mDNSによる解決
- mdns_minimal: mDNSによる解決 (.local ドメインのみ)

#### NIS (Network Information Service)
- ネットワーク上の複数のマシン間でシステム情報をサーバとして一元管理し、クライアントマシンへ共有する仕組み
  - ユーザーアカウント (/etc/passwd) 、パスワード (/etc/shadow) 、グループ (/etc/group) 、ホスト名 (/etc/hosts) 、
    サービス名 (/etc/services) などを管理していた
- Unix環境で広く使われていた (2026年現在はLDAP / Active Directory、FreeIPAなどが主流)

#### LDAP (Lightweight Directory Access Protocol)
- NISを置き換える仕組み
  - データをツリー構造で階層管理する
  - データ型のスキーマを拡張できる
  - 通信はTLSによる暗号化に対応
  - エントリ・属性ごとに細かいアクセス制御ができる
  - 複数サーバーでの分散・レプリケーションが柔軟

## 参照
- [「/etc/nsswitch.conf」ファイル](https://linuc.org/study/knowledge/508/)
