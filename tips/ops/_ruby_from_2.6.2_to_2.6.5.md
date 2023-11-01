# Ruby2.6.5バージョンアップメモ
- 2.6.3
  - https://www.ruby-lang.org/ja/news/2019/04/17/ruby-2-6-3-released/
    - 新元号「令和」の追加
- 2.6.4
  - https://www.ruby-lang.org/ja/news/2019/08/28/ruby-2-6-4-released/
    - RDocにおけるjQueryの脆弱性の修正
- 2.6.5
  - https://www.ruby-lang.org/ja/news/2019/10/01/ruby-2-6-5-released/
    - Shell#[]およびShell#testのコード挿入脆弱性
    - WEBrick における HTTP レスポンス偽装の脆弱性修正
    - File.fnmatch の NUL 文字挿入脆弱性
    - WEBrickのDigest認証に関する正規表現Denial of Serviceの脆弱性

## トラブルシューティング
### .circleci/config.ymlのimage変更後、buildに失敗するようになった
```yml
docker:
  - image: circleci/ruby:2.6.5-stretch-node-browsers-legacy
```
- 参照: [CircleCI で Node.js のバージョンが合わない(2019年11月)](https://qiita.com/oieioi/items/dc03abfbb5fd55c7b3d4#%E5%8E%9F%E5%9B%A0)

#### 解決方法
- ローカルにnode12.13をインストールし、バージョン切り替え(nodebrew)
```
$ nodebrew install v12.13.0
$ nodebrew use v12.13.0
```
- package.jsonのバージョンを12系に書き換え
```json
    "node": "12.X",
```
- `node_modules`削除 -> `$ yarn install`
- .circleci/config.ymlで指定されているnodeのバージョンを10系 -> 12系へ変更
```yml
docker:
  - image: circleci/node:12-browsers-legacy
```

### Heroku環境とNodeのバージョンが合わない
```
$ heroku run bash --app sushi
$ node -v
v12.14.1
```

#### 解決方法
- ローカルにnode12.13をインストールし、バージョン切り替え(nodebrew)
```
$ nodebrew install v12.14.1
$ nodebrew use v12.14.1
```
- .node_versionのversionを書き換え
```
12.14.1
```
