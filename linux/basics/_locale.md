# locale
- 参照: Linuxプログラミングインターフェース 10章

## TL;DR
- 言語や文化に由来するサブセット

### 国際化(i18n)
- 複数地域で動作可能に開発されたプログラムがlocaleに正しく対応しており、
  ユーザーに合った言語や形式で処理されること

### 地域化(localization)
- その地域で動作可能に開発されたプログラムがlocaleに正しく対応しており、
  ユーザーに合った言語や形式で処理されること

## locale定義
- localeは外部ファイル`/usr/share/locale`にて定義される
  - ディレクトリ以下の1ファイルが1地域のlocale情報に対応する
  - 命名規約`language[_territory[.codeset]][@modifier]`によってファイル名が決まる
    - `language` - 2文字のISO言語コード
    - `territory` - 2文字のISO国コード
    - `codeset` - 文字エンコーディングセット
    - `modifier` - localeディレクトリを特定する付加情報
  - プログラムで使用するlocaleを指定するためには`/usr/share/locale`以下のサブディレクトリを指定する

### localeサブディレクトリ
- 変換内容の定義ファイル/ディレクトリ
  - `LC_CTYPE` - 文字クラス・大文字小文字変換規則
  - `LC_COLLATE` - 比較/照合規則
  - `LC_MONETARY` - 通貨表記規則
  - `LC_NUMERIC` - 通貨以外の数値の表記規則
  - `LC_TIME` - 日付と時刻の表示規則
  - `LC_MESSAGES` - yes/noの応答やその他のメッセージの表記規則を記述したファイルを置くディレクトリ

## API
### `setlocale(3)`
- プログラムのlocaleを参照・変更する

#### 引数
- `category`、`*locale`を指定する
  - `category` - localeサブディレクトリのカテゴリ
  - `*locale` - locale文字列

#### 返り値
- 新たに設定したlocaleを表す文字列へのポインタを返す
  - エラー時はNULLを返す
