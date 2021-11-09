# キャッシュを削除したい
## 動機
- CircleCIには手動でキャッシュする機構がない

## キャッシュを行なっている場面
- 仮想環境のイメージをダウンロードしてビルドする際
- `$ bundle install`する際

## 解決方法
- キャッシュを行なっている単位を確認する
  - `.Branch` / `.Revision` etc
- キャッシュをクリアできるような変更を行う
  - Ex. `Revision`に対してキャッシュを行なっている -> 空コミットを積む
- sshでコンテナに接続し`$ docker images --no-trunc --format '{{.ID}}' | xargs docker rmi`を実行
  - [キャッシュされた Docker レイヤーを削除するには？](https://support.circleci.com/hc/ja/articles/360007406013-%E3%82%AD%E3%83%A3%E3%83%83%E3%82%B7%E3%83%A5%E3%81%95%E3%82%8C%E3%81%9F-Docker-%E3%83%AC%E3%82%A4%E3%83%A4%E3%83%BC%E3%82%92%E5%89%8A%E9%99%A4%E3%81%99%E3%82%8B%E3%81%AB%E3%81%AF-)
