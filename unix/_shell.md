# シェル
#### 使用できるシェル一覧
```
$ cat /etc/shells
```

## 設定ファイル読み込み順
### zsh: ログインシェル
1. `/etc/zshenv`
2. `~/.zshenv`
3. `/etc/zprofile`
4. `~/.zprofile` - 環境変数など
5. `/etc/zshrc`
6. `~/.zshrc` - エイリアス・`EDITOR`変数・プロンプト設定
7. `/etc/zlogin`
8. `~/.zlogin`

#### インタラクティブモード
1. `/etc/zshenv`
2. `~/.zshenv`
3. `/etc/zshrc`
4. `~/.zshrc`

### bash: ログインシェル
1. `/etc/profile`
2. `~/.bash_profile` or `~/bash_login` or `~/.profile` - 環境変数など
3. `~/.bashrc`
4. `/etc/bashrc`

#### インタラクティブモード
- `~/.bashrc`

### 参照
- [bashとzshの違い。bashからの乗り換えで気をつけるべき16の事柄](https://kanasys.com/tech/803)
- [ユーザーの環境変数を設定するbashの設定ファイルと、カスタムプロンプトについて](https://oxynotes.com/?p=5418)
