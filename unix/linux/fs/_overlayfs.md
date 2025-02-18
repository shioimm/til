# Overlayファイルシステム[Linux 3.18~]
- あるディレクトリを別のディレクトリに重ね合わせ、重ね合わせた結果をマウントする仕組み
- Dockerコンテナのレイヤー構造を構築するユースケースなどに使用される
  - その他contained、CRI-Oなど

## レイヤー構造
- 最上位ディレクトリは全てのレイヤーをマージ・マウントしたディレクトリ
- 上層ディレクトリ内のファイルは読み書き両用
- 下層ディレクトリ内のファイルは読み取り専用
  - 下層ディレクトリ内のファイルに書き込みを行う場合、ファイルは上層ディレクトリにコピーされる

```
merged/ = file1(lower1), file2(lower2), file3(upper)
  |
upper/  = file3(lower3のファイルを編集)
  |
lower1/ = file1
  |
lower2/ = file1, file2
  |
lower3  = file3
```

```
# 前提: ファイルを格納したディレクトリlower1/, lower2/, lower3/,
#       上層ディレクトリupper/, 最上層ディレクトリmerged/,
#       カーネルが作業に使うディレクトリwork/が存在する

$ sudo mount -t overlay 識別名 -o lowerdir=lower1:lower2:lower3,upperdir=upper,workdir=work merged

$ tree ./merged
merged/
├── file1
├── file2
└── file3

0 directories, 3 files
```

## 参照
- イラストでわかるDockerとKubernetes
