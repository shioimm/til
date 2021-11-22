# .gitconfig
- [user]
  - name
  - email
- [include] # 別ファイルをロードする
  - path = ~/.gitconfig.local
- [core]
  - editor
  - excludesfile = ~/.gitignore # Gitで管理しないファイル
  - pager = "less -R -F -X" # ページャ
- [color]
  - ui = auto
- [alias] # エイリアス
- [hub] # hubコマンドによるGitHub操作時の設定
  - protocol = https
- [push] # push操作時の設定
  - default = nothing
- [pull] # pull操作時の設定
  - ff = only
- [rerere] # reuse recorded resolution
  - enabled = true

#### ~/.gitconfig
- `$HOME`に.gitconfigを置くとgitコマンドが使える全てのディレクトリに対してconfigを有効化できる
