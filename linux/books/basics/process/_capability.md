# ケーパビリティ
- 参照: Linuxプログラミングインターフェース 39章

## TL;DR
- UNIXの特権プロセスが持つ権限の検査を機能別に有効化・無効化及び検査する方式
  - 従来の権限検査ではプロセスに特権プロセスと一般プロセスの区分しかなく、
    プロセスに必要以上の権限を付与してしまうケースがある
  - スーパーユーザー権限を細分化したケーパビリティという単位で権限検査を行うことにより
    きめ細かに権限付与を行うことができる

### 現代のケーパビリティ実装
- 権限を必要とするすべての処理に対し必要なケーパビリティがプロセスに設定されているかどうかをカーネルが検査する
- カーネルはプロセスのケーパビリティを設定・参照するシステムコールを実装する
- カーネルは実行ファイルにケーパビリティを設定する機能を実装する
  カーネルは実行ファイルを実行するプロセスにケーパビリティを付与するAPIを実装する

## Linuxのケーパビリティ
- Linuxプログラミングインターフェース 39章 P844

## ケーパビリティセット
- `permitted` / `effective` / `inheritable`
- それぞれのケーパビリティセットにケーパビリティを複数設定することが可能

### プロセスのケーパビリティセット
- `permitted`
  - プロセスが`effective` / `inheritable`に設定できるケーパビリティセット
- `effective`
  - カーネルがプロセスの権限検査に使用するケーパビリティセット
- `inheritable`
  - プロセスがプログラムを実行する際に受け継いで良いケーパビリティセット

### ファイルのケーパビリティセット
- そのファオルを実行するプロセスのケーパビリティセット
- `permitted`
  - `exec`時に、プロセスが持つケーパビリティとは無関係に
    プロセスの`permitted`セットに追加するケーパビリティセット
- `effective`
  - 1ビットで表現される
  - 設定時、`exec`時にプロセスの新`permitted`ケーパビリティセット
    および新`effective`ケーパビリティセットを有効にする
  - 解除時、プロセスの新`effective`ケーパビリティセットを空にする
- `inheritable`
  - プロセスの`inheritable`ケーパビリティセットをマスクし、
    `exec`後のプロセスの`permitted`ケーパビリティセットに設定可能なケーパビリティを決定する

## 新ケーパビリティセットの算出規則
`exec`後のプロセスに設定されるケーパビリティセット

```
P'(permitted)   = (P(inheritable) & F(inheritable)) | (F(permitted) & cap_bset)

P'(effective)   = F(effective) ? P'(permitted) : 0

P'(inheritable) = P(inheritable)
```

## ケーパビリティバウンディングセット
- `exec`時にプロセスへ付与するケーパビリティに制限を設けるセキュリティ上の機能

## root権限
- rootユーザーは全権限を維持するため、rootによる`exec`時ファイルケーパビリティセットは無視される

## プロセスのユーザーID変更
- それまでの実ユーザーID、実効ユーザーID、saved set-user-IDいずれかの値が0の場合
  ユーザーIDを変更するとユーザーIDは全て0以外になり、全ケーパビリティは恒久的に放棄される
- 実効ユーザーIDを0から0以外へ変更する場合
  `effective`ケーパビリティを全て解除する
- 実効ユーザーIDを0以外から0へ変更する場合
  `permitted`ケーパビリティセットを`effective`ケーパビリティセットへ代入する
- filesystem user IDを0から0以外へ変更する場合
  一部ファイル関連のケーパビリティを`effective`ケーパビリティセットから解除する
- filesystem user IDを0以外から0へ変更する場合
  `permitted`ケーパビリティセットに設定されている一部ファイル関連のケーパビリティを
  全て`effective`ケーパビリティセットへ設定する

## プログラムからのプロセスケーパビリティ変更
- `libcap` APIを使用して操作を行う

### 操作手順
1. `cap_get_proc(3)`を実行し、
   プロセスの現在のケーパビリティをカーネルから`cap_t`構造体型のユーザー空間へ取得
2. `cap_set_flag(3)`を実行し、
   取得したユーザー空間の構造体にある`permitted` / `effective` / `inheritable`ケーパビリティセットへ
   ケーパビリティを設定・解除
3. `cap_set_proc(3)`を実行し、
   ユーザー空間の`cap_t`構造体をカーネルへ渡し、プロセスケーパビリティを更新
4. `cap_free(3)`を実行し、
   `libcap` APIが割り当てた構造体を解放

## `securebits`
- ケーパビリティに完全対応したシステムでは`root`は特別扱いしない
- `securebits`スレッド属性によってプロセス単位にフラグを設け、
  3種類ある`root`の特別扱いを個別に有効化・無効化する