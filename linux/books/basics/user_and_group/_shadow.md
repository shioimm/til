# シャドーパスワードファイル
- `/etc/shadow` - 暗号化されたパスワードを格納するためのファイル
- シャドーパスワードがあれば通常の`/etc/passwd`は誰でも読み取れる

```
account:password:last:maybe:mustbe:warned:expires:disabled:reserved

* account - ユーザ名
* password - 暗号化されたパスワード
* last - 1970年1 月1日から最後更新日までの日数
* may - パスワードが変更可能となるまでの日数
* must - パスワードを変更しなくてはならなくなる日までの日数
* warned - パスワード有効期限が来る前にユーザが警告を受ける日数
* expires - パスワード有効期限経過後アカウント使用不能までの日数
* disabled - 1970年1月1日からアカウント使用不能日までの日数
* reserved - 予約フィールド
```

- `<shadow.h>`で定義される`spwd`構造体に格納される

```c
struct spwd {
  char *sp_namp;  // ユーザーログイン名
  char *sp_pwdp;  // 暗号化されたパスワード
  long sp_lstchg; // 1970年1月1日~パスワード最終変更日まで日数
  int  sp_min;    // パスワードが変更出来るようになるまでの日数
  int  sp_max;    // パスワードの変更が必要になるまでの日数
  int  sp_warn;   // パスワード失効の警告をする日数
  int  sp_inact;  // アカウントが不活性になるまでの日数
  int  sp_expire; // 1970年1月1日~アカウントが使用不能となるまでの日数
  int  sp_flag;   // 予約
}
```
