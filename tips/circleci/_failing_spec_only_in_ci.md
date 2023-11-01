# [CircleCI]masterブランチでだけ落ちるテスト
## 挙動
- 開発ブランチでテストが通ったためmasterにマージしたところ、masterでテストが落ちるようになった
  - feature specがランダムに落ちる
  - ローカルでは通っている
  - masterをrebaseした開発ブランチでは通っている

## 原因
- CircleCIが利用しているDocker imageが更新されたため
  - `circleci/ruby:2.6.5-stretch-node-browsers-legacy`
- ローカル実行環境とCI実行環境が異なるため

## 対策
- `browsers-legacy`imageはPhantomJSを含むが、ローカルではPhantomJSを使用していない
- `circleci/ruby:2.6.5-stretch-node-browsers`を使用するように変更
