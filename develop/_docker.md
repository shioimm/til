### はしがき
- Docker = コンテナ仮想環境
  - `docker-compose up` -> docker-compose.ymlに基づき環境を立ち上げる
    - `-d`オプションでデーモン化
  - `docker-compose down` -> 立ち上げた環境を(DBに保存されたデータごと)捨てる
    - version: 2以降ではvolumesを指定することで保存されたデータを復元
  - アプリケーションはローカルに整備した環境 + 仮想環境で動作する
    - TIPs: 最初は最小の単位で仮想環境を使う(PGのみ、Redisのみなど)
