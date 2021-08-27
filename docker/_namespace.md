# Namespace
- 特殊なフラグを指定して実行されるプロセス
- リソースを他のプロセスから隔離する機能として利用される
- Namespaceの子プロセスはNamespaceのメンバとなる
- DockerはNamespaceを使用してコンテナ同士を隔離する

## コンテナ実行時の動作
1. Dockerデーモンはそのコンテナ専用のNamespaceとなるプロセスを作成する
2. DockerデーモンはNamespaceのメンバとしてコンテナに含まれるプロセスを実行する

## Namespaceの種類

| Namespace | リソース                                 |
| -         | -                                        |
| Mount     | ファイルシステムのマウントポイント       |
| IPC       | プロセス間通信に関するリソース           |
| Network   | ネットワークインターフェース・ポート番号 |
| UTS       | ホスト名                                 |
| PID       | プロセスID(Linux 3.8~)                   |
| User      | UID / GID(Linux 3.8~)                     |
| Cgroup    | cgroup(Linux4.6~)                        |
| Time      | システムクロックの一部(Linux 5.6~)       |

### cgroup
- プロセスが使用可能なリソースに対して設定を行う機能
- コンテナが利用可能なハードウェアリソースの上限やデバイスファイルへの権限を設定するために利用される

#### サブシステム(リソースコントローラ)
- 各リソースを管理するカーネルのコンポーネント

#### cgroupfs
- サブシステムへの設定を行うためのファイルシステム
- cgroupfsはディレクトリに沿った階層構造
- 各ディレクトリが各control group(制限の対象となるプロセスの集合)に対応する
- 各プロセスはいずれかのcontrol groupに所属する
- 各ディレクトリのファイルを通じて設定を適用する
  - 上位のcgroupの設定は下位のcgroupへ引き継がれる
  - 下位のcgroupは上位のcgroupによって設定された制限を超えない

## 参照
- [Docker](https://www.docker.com/)
- [Docker 概要](https://docs.docker.jp/get-started/overview.html)
- [Docker入門（第一回）～Dockerとは何か、何が良いのか～](https://knowledge.sakura.ad.jp/13265/)
- [Docker入門（第二回）～Dockerセットアップ、コンテナ起動～](https://knowledge.sakura.ad.jp/13795/)
- [Docker入門（第四回）～Dockerfileについて～](https://knowledge.sakura.ad.jp/15253/)
- [Dockerイメージの理解とコンテナのライフサイクル](https://www.slideshare.net/zembutsu/docker-images-containers-and-lifecycle)
- [【連載】世界一わかりみが深いコンテナ & Docker入門 〜 その2:Dockerってなに？ 〜](https://tech-lab.sios.jp/archives/19073)
- [Rails on Docker](https://speakerdeck.com/sinsoku/rails-on-docker)
- 仮想化&コンテナがこれ1冊でしっかりわかる教科書
- イラストでわかるDockerとKubernetes
- [7. Docker 入門](https://tomomano.github.io/learn-aws-by-coding/#sec_docker_introduction)
