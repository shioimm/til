# プロセス
## 各プロセスに付随する識別情報
### プロセスを開始したのが実際に誰であるかを表すID
- ログインした際にパスワードファイルの該当エントリから取得する
- 実ユーザID (Real User ID, RUID)
  - プロセスを開始したユーザのID
  - 子プロセスは通常親プロセスのRUIDを継承
- 実グループID (Real User ID, RUID)
  - プロセスを開始したユーザの所属するプライマリグループのID
  - 子プロセスは通常親プロセスのRGIDを継承

### ファイルアクセスやシステムコールの権限の判定に使用するID
- SUID / SGIDビットや`setuid()` / `setgid()` 系システムコールによって動的に変わる
- 実効ユーザID (Effective User ID, EUID)
-  実効グループID (Effective Group ID, EGID)
-  補助グループID (Supplementary Groups)

### 関数execが保存するID
- プログラムが動作した時の実効ユーザIDと実効グループIDのコピー
- 保存セットユーザID (Saved Set User ID, SUID)
- 保存セットグループID (Saved Set Group ID, SGID)
