# Vagrant
- 参照: [Vagrant](https://www.vagrantup.com/)
- 参照: [Vagrant](https://ja.wikipedia.org/wiki/Vagrant_(%E3%82%BD%E3%83%95%E3%83%88%E3%82%A6%E3%82%A7%E3%82%A2))

## TL:DR
- 仮想マシンを構築するためのソフトウェア
- Vagrantfileに基づき環境の構築から設定までを自動的に行う
- 仮想マシン自体は仮想化ソフトウェア(VirtualBoxなど)によって提供され、Vagrantは設定や立ち上げのみを行う

## Utility
### ホストマシンからsshログインしたい
- Vagrantのssh-configをホストマシンの`.ssh/config`に追加する
```
$ vagrant ssh-config --host ゲストマシンのIPアドレス >> ~/.ssh/config
```

### ホストマシンからゲストマシンへscpでファイルを転送したい
- `.ssh/config`を利用する
```
$ scp -F ~/.ssh/config /path/to/転送元のファイル ゲストマシンのIPアドレス:/path/to/転送先のディレクトリ
```
