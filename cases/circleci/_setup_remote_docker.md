# Dockerデーモンが利用できない
- Rerun job with SSHでコンテナ (CircleCIが立ち上げたコンテナ) 内に入った際、Dockerデーモンを操作できない

```
Cannot connect to the Docker daemon at unix:///var/run/docker.sock.
Is the docker daemon running?
```

- .circleci/config.ymlに`setup_remote_dockerステップを追加する

```yml
jobs:
  build:
    steps:
      # ...
      - setup_remote_docker:
          version: 19.03.13
```

## 参照
- [Docker デーモンが利用できない](https://support.circleci.com/hc/ja/articles/115015849028-Docker-%E3%83%87%E3%83%BC%E3%83%A2%E3%83%B3%E3%81%8C%E5%88%A9%E7%94%A8%E3%81%A7%E3%81%8D%E3%81%AA%E3%81%84)
