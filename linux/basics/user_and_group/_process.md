# プロセスの権限
- 全てのプロセスは、その属性としてプロセスの権限を持つ
  - 実ID   - 実ユーザーID / 実グループID
  - 実効ID - 実効ユーザーID / 実効グループID
  - set-ID - set-UID / set-GID
  - filesystem user ID / filesystem group ID
  - 追加グループID
- ファイルは実IDとsaved set-IDビットで表されるパーミッションを持つ

#### 実ID
- プロセスのオーナー
- ログインシェルはパスワードファイルに記述されているフィールドを参照し、
  実ユーザーID / 実グループIDを決定する
  全てのプロセスはシェルの子孫であるため、
  起動時にシェルの実ユーザーID / 実グループIDを受け継ぐ

#### 実効ID
- 実効ユーザーID - そのプロセスを実行するユーザーのユーザーID
- 実効グループID - そのプロセスを実行するユーザーのグループID
- ほとんどの場合実IDに一致する
- 実効ID`0` = スーパーユーザー

#### set-ID
- set-UID - 実行中のプロセスの実効ユーザーIDを実行ファイルオーナーの実ユーザーIDとする
- set-GID - 実行中のプロセスの実効グループIDを実行ファイルオーナーの実グループIDとする

#### set-user-ID / set-group-ID操作
```
$ chmod u+s prog // set-user-IDビットをセット
$ chmod g+s prog // set-group-IDビットをセット
```
- ファイルのユーザー / グループ以外のユーザーが対象のファイルを操作できるようにする仕組み
- ファイルの実効許可を持つ任意のプロセスがset-IDが付与されたファイルを実行する時、
  ファイルの実IDが当該プロセスの実効IDに置き換わる

#### Linuxにおいてset-user-ID / set-group-IDされたプログラム
- `passwd(1)`
- `mount(8)` / `unmount(8)`
- `su(1)`
- `wall(1)`
- その他

#### saved set-ID
- set-user-ID / set-group-IDと共に使用される
- set-user-ID / set-group-IDビットがセットされている場合、
  プロセスの実効IDを実行ファイルのオーナーの実IDに一致させる
  セットされていなければプロセスの実効IDは変更しない
- プロセスの実効IDをsaved set-IDにコピーする
  実行ファイルにset-IDビットがセットされているか否かに関わらず行う

#### filesystem user ID / filesystem group ID
- プロセスがファイルシステムに対する操作を行う内に照合される権限
  - Ex. ファイルの開閉、オーナーの変更、パーミッションの変更
- 原則実効IDに一致する
  - 他のUNIXシステムでは実効IDによって権限を照合する
  - set-user-ID / set-group-IDされ実効IDが場合は
    filesystem user ID / filesystem group IDも変更される
  - `setfsuid(2)` / `setfsgid(2)`によりfilesystem IDのみの変更も可能

#### 追加グループID
- プロセスが属する補助的なグループ
- 実効ID、filesystem IDと組み合わせてパーミッション検査時に参照される
- `getgroups(2)`で参照、
  特権プロセスなら`setgroups(2)` / `initgroups(2)`で変更可能

## 参照
- Linuxプログラミングインターフェース 9章
