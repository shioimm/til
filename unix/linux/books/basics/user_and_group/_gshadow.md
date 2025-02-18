# グループシャドーパスワードファイル
- `/etc/gshadow` - 暗号化されたグループのパスワードを格納するためのファイル

```
group_name:password:administrator_list:member_list

* group_name - グループ名
* password - 暗号化されたパスワード
* administrator_list - グループに所属する管理ユーザーのリスト (コンマ区切り)
* member_list - グループに所属するユーザー名のリスト (コンマ区切り)
```
