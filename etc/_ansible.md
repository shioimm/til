# Ansible
- 参照: [Ansible Documentation](https://docs.ansible.com/ansible/latest/index.html)
- 参照: [Ansible (ソフトウェア)](https://ja.wikipedia.org/wiki/Ansible_(%E3%82%BD%E3%83%95%E3%83%88%E3%82%A6%E3%82%A7%E3%82%A2)

## TL;DR
- RedHatが開発する構成管理/オーケストレーション/デプロイメントツール
  - 設定ファイルに従いソフトウェアのインストールや設定を自動的に実行する事が出来る

### 特徴
- シンプルさと使いやすさ
- エージェントレス - Pythonが使用可能でOpenSSHが疎通する機器に対して利用が可能

## 構成要素
### Control node
- Ansibleがインストールされている機器
- 制御コマンド(`$ /usr/bin/ansible`)やPlaybook(`$ /usr/bin/ansible-playbook`)を実行する

### Managed nodes
- Ansibleで管理するネットワークデバイス(ホスト)
- Ansibleのインストールは不要

### Inventory
- Managed nodesのリスト(ホストファイル)
- Managed nodesのIPアドレスなどの情報を設定したり、グループ単位で整理することができる

### Modules
- Ansibleが実行するコードの単位
- Ansibleに用意されている
- Task単位で個別に呼び出したり、Playbookでまとめて複数呼び出すことが可能

### Tasks
- Ansibleにおけるアクションの単位
- ad-hocコマンドで一つのタスクを一回実行することができる

### Playbooks
- Ansibleにおいて順序立てられたタスクのリスト
- 繰り返し実行が可能
- YAMLで記述される
