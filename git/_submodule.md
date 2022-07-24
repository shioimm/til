# submodule
## サブモジュールの追加
#### 既存のリポジトリを作業中のリポジトリのサブモジュールとして追加

```
$ git submodule add https://github.com/***/***

# サブディレクトリと.gitmodulesが追加される
# (.gitmodules - 追加したサブディレクトリと追加したサブモジュールのリポジトリのURLの対応)
```

#### サブモジュールを含むプロジェクトのクローン

```
$ git clone --recursive https://github.com/***/***
```

## サブモジュールのdiffを確認

```
$ git diff --submodule
```

## サブモジュールの変更
#### サブモジュールをサブモジュールのmainに追随させる

```
$ git submodule update --remote

# サブモジュールのリポジトリのmainブランチの内容まで手元にチェックアウトした内容を更新する
```

#### サブモジュールにローカルで変更を加える

```
$ cd <SubDirName>/

# 変更を行う
$ git commit -m '<Commit Message>'

$ cd ..

# リモートmainの変更を取り込む
$ git submodule update --remote --rebase
```

## 参照
- [7.11 Git のさまざまなツール - サブモジュール](https://git-scm.com/book/ja/v2/Git-%E3%81%AE%E3%81%95%E3%81%BE%E3%81%96%E3%81%BE%E3%81%AA%E3%83%84%E3%83%BC%E3%83%AB-%E3%82%B5%E3%83%96%E3%83%A2%E3%82%B8%E3%83%A5%E3%83%BC%E3%83%AB)
