# Gentoo
- 参照: [About Gentoo](https://www.gentoo.org/get-started/about/)
- 参照: [Gentoo Linux](https://ja.wikipedia.org/wiki/Gentoo_Linux)

## TL;DR
- Gentoo系Linuxディストリビューション
- パッケージ管理システムにPortageを利用しており、
  あらゆるアプリケーションやニーズに応じて自動的に最適化、カスタマイズすることができる
- 自分でソフトウェアをコンパイルする点が特徴的
  - ユーザーによってコンパイルオプションを調整可能

### 構築方法
- LiveCDでシステムを起動
  -> 起動に必要な最小限の実行ファイル(Ex. カーネル)をインターネット経由でダウンロード
  -> `Chroot`コマンドなどを実行
  -> Portageを使ってシステムを構築

## Portage
- Gentooの公式パッケージマネージャでありソフトウェア配布システム
- バイナリではなくソースコードから構築を行う点が特徴的
- ebuildを参照しシステムを構築する
  - ebuild -> パッケージのインストール手順を記したスクリプト
  - emerge -> ebuildに従ってソースコードをダウンロード、コンパイル、所定のディレクトリへインストールするコマンド
