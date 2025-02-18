# グループファイル
- グループデータベース
```
group_name:password:GID:user_list

* group_name - グループ名
* password - 空欄 (以前は暗号化されたパスワードが入っていたが現在は/etc/gshadowで保存)
* GID - グループID
* user_list - グループに所属するユーザー名のリスト(コンマ区切り)
```

- `<grp.h>`で定義される`group`構造体に格納される

```c
struct group {
  char  *gr_name;   // グループ名
  char  *gr_passwd; // 暗号化されたグループのパスワード
  gid_t gr_gid;     // グループ ID
  char  **gr_mem;   // グループの各ユーザー名へのポインタの配列名
};
```

## API
- `getgrgid(3)` - グループIDの検索
- `getgrnam(3)` - グループ名の検索
- `getgrant(3)` - グループファイル全体の検索
