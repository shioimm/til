# Docker
- 参照: [Docker](https://www.docker.com/)
- 参照: [Docker入門（第二回）～Dockerセットアップ、コンテナ起動～](https://knowledge.sakura.ad.jp/13795/)
- 参照: [Docker入門（第四回）～Dockerfileについて～](https://knowledge.sakura.ad.jp/15253/)

## TL;DR
- Dockerコンテナイメージ
  - アプリケーションを実行するために必要な要素を含む、ソフトウェアパッケージ
    - 軽量かつスタンドアロンで実行可能
    - コード、ランタイム、システムツール、システムライブラリ、設定など
- DockerコンテナイメージをDocker Engine上で実行すると、イメージがコンテナになる
- コンテナ化されたアプリケーションは実行環境に関わらず常に同じように実行される

## ライフサイクル
1. Docker HUBからDockerコンテナイメージを取得
    - イメージは自ら作成することも可能 -> Dockerfileを作成
    - DockerfileにはベースとするDockerイメージに対し、実行する内容を記述
2. DockerコンテナイメージをDocker Engine上で実行
3. Dockerコンテナが起動
4. - 略 -
5. Dockerコンテナを削除
6. Dockerイメージを削除

## ツール
### Docker HUB
- [コンテナイメージ共有リポジトリ](https://www.docker.com/products/docker-hub)
  - パブリックリポジトリ
  - プライベートリポジトリ

### Docker Desktop
- コンテナ化アプリケーションの構築と共有を行うためのデスクトップアプリケーション

## コマンド
- `$ docker-compose up` -> docker-compose.ymlに基づき環境を立ち上げる
  - `-d`オプションでデーモン化
- `$ docker-compose down` -> 立ち上げた環境を(DBに保存されたデータごと)捨てる
  - version: 2以降ではvolumesを指定することで保存されたデータを復元
