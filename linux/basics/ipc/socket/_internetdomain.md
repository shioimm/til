# インターネットドメインソケット
- 参照: Linuxプログラミングインターフェース 59章

## TL;DR
- ストリームソケットはTCPを使用する
- データグラムソケットはUDPを使用する
  - インターネットドメインのUPDは信頼性を備えていない
  - インターネットドメインのUDPは受信ソケット側のキューが一杯になると
    送信されたデータグラムは暗黙的に破棄される
- インターネットドメインのソケットアドレスはIPアドレス + ポート番号

## ネットワークバイトオーダ
- IPアドレス・ポート番号は整数のため、
  送受信の際に複数バイトからなる整数の格納・表現方法が異なるハードウェアアーキテクチャに
  それぞれ対応する必要がある
- ホストバイトオーダ - マシン上のバイト格納順序
- ネットワークバイトオーダ - IPアドレス、ポート番号の統一的なバイト格納順序
  - ホストバイトオーダはハードウェアによってアーキテクチャが異なるため、
    ソケットのアドレス構造体へ代入する前にネットワークバイトオーダへ変換が必要

### ビッグエンディアン
- 整数の最上位バイト(メモリアドレスの下位)を先に格納するアーキテクチャ
- Ex. ネットワークバイトオーダ、x86以外の多くのアーキテクチャ

### リトルエンディアン
- 整数の最下位バイト(メモリアドレスの上位)を先に格納するアーキテクチャ
- Ex. x86

### マーシャリング
- ネットワークを介して異種システム間でデータを交換する際、
  コンピュータアーキテクチャの違いを考慮するためデータを標準形式へ変換すること
  - 統一的な規約に則って送信側はデータをエンコーディングし、受信側はデコーディングする
- Ex. EDR、ASN.1-BER、XML、JSON、テキスト形式(改行をデータ区切りに用いる)

## インターネットソケットアドレス
- IPv4 / IPv6両方を使用可能なホストではポート番号を共有するため、
  別のサービスにはそれぞれ別のポート番号をバインドする必要がある

### IPv4アドレス構造体

```c
#include <netinet.h>

// sockaddr_in構造体 - IPv4ソケットアドレス
struct sockaddr_in {
  sa_family_t    sin_family;  // アドレスファミリ(AF_INET)
  in_port_t      sin_port;    // ポート番号
  struct in_addr sin_addr;    // IPv4アドレス(INADDR_ANY)
};

struct in_addr {
  inaddr_t s_addr; // 符号なし32ビット整数
};
```

### IPv6アドレス構造体

```
#include <netinet.h>

// sockaddr_in6構造体 - IPv6ソケットアドレス
struct sockaddr_in6 {
  sa_family_t     sin6_family;   // アドレスファミリ(AF_INET6)
  in_port_t       sin6_port;     // ポート番号
  uint32_t        sin6_flowinfo; // IPv6フロー情報
  struct in6_addr sin6_addr;     // IPv6アドレス(INADDR_ANY)
  uint32_t        sin6_scope_id; // スコープID
};

struct in6_addr {
  uint8_t s6_addr[16]; // 16バイト(128ビット)
};
```

### `sockaddr_storage`構造体
- どの種類のソケットアドレスにも対応できるサイズを持ち、
  IPv4 / IPv6どちらのソケットアドレスにも透過的に代入可能

```c
// クライアントからの受信時にバイト数が不明の場合に使用する

struct sockaddr_storage {
  sa_family_t ss_family;   // アドレスファミリ
  char        sa_data[14]; // 任意のデータ
};

// 任意のsockaddr構造体(sockaddr_in / sockaddr_in6)を格納できる入れ物として機能する
```

```c
// Software Design 2021年5月号 ハンズオンTCP/IP

struct sockaddr_storage ss;
socklen_t sslen = sizeof(ss);

accept(sock, (struct sockaddr *)&ss, &sslen);

if (ss.ss_family == AF_INET) {
  struct sockaddr_in *s_in;
  s_in = (struct sockaddr_in *)&ss;
} else if (ss.ss_family == AF_INET6) {
  struct sockaddr_in *s_in6;
  s_in = (struct sockaddr_in6 *)&ss;
}
```

## ホスト名・サービス名
- ホストアドレスはバイナリ形式・ホスト名・可読形式のいずれかによって表現する
  - ホスト名 - ネットワークに接続したシステムを表すシンボル
- ポート番号はバイナリ形式・サービス名のいずれかによって表現する
  - サービス名 - ポート番号を表すシンボル

### ホスト名・サービス名の変換関数種別
- ドット区切りの10進数で表現したIPv4アドレス - バイナリ形式間の変換(使わない)
- バイナリ形式のIPv4 / IPv6アドレス - 可読形式間の変換
- ホスト名・サービス名 - バイナリ形式間の変換

### ホスト名・サービス名の新旧変換関数API
- `inet_aton(3)` / `inet_ntoa(3)` -> `inet_pton(3)` / `inet_ntop(3)`
- `gethostbyname(3)` / `gethostbyaddr(3)` -> `getaddrinfo(3)` / `getnameinfo(3)`
- `getservbyname(3)` / `getservbyport(3)` -> `getaddrinfo(3)` / `getnameinfo(3)`

## DNS
- ホスト名に対応するIPアドレスを取得するための機構

### 特徴
- DNSはホスト名を階層名前空間で管理する
  - DNS階層構造中の各ノードが最長63文字のラベル(名前/バイト単位)を持つ
  - ルートノードは名前を持たない無名ノード
- ノードのドメイン名はそのノードからルートまでの全ての名前を`.`で連結したもの
  - 完全修飾ドメイン名 - ノードからルートまでの連結・DNS階層構造内でホストを特定するもの
- DNS階層構造全体を管理する組織は存在せず、階層的に構築される各DNSサーバーが
  木構造の枝の部分を管理する
  - ゾーンの管理者はゾーンへのホストの追加、ホスト名とIPアドレスの対応付けの更新を行う
- `getaddrinfo(3)`はリゾルバライブラリを使用してローカルDNSサーバーと通信する
  対象のドメイン名が見つかるまでDNS階層構造内で問い合わせを行いドメイン名を解決する

#### 再帰問い合わせ
- 問い合わせを受けたDNSサーバーが必要に応じ他のDNSサーバーへ二次的な問い合わせを全て処理する

#### 反復問い合わせ
- ローカルDNSサーバーがルートサーバーから順に上位から下位階層に向かって順に問い合わせを行う

### トップレベルドメイン
- 最上位の無名ルート直下のノード
  - 汎用ドメイン
  - 国ドメイン

### `/etc/services`
- well-knownポートのみを一元管理するファイル
- `getaddrinfo(3)`は`/etc/services`ファイルを参照しポート番号とサービス名を相互に変換する
- `/etc/services`ファイルはサービス名・プロトコル・オプションのフィールドを持つ

## API
### `htons(2)` / `htonl(2)`
- `htons(2)` - 16ビットの符号なし整数をネットワークバイトオーダに変換する
- `htonl(2)` - 32ビットの符号なし整数をネットワークバイトオーダに変換する

#### 引数
- `htons(2)` - `host_uint16`を指定する
  - `host_uint16` - 16ビットの符号なし整数
- `htonl(2)` - `host_uint32`を指定する
  - `host_uint32` - 32ビットの符号なし整数

#### 返り値
- それぞれの引数をネットワークバイトオーダに変換した値

### `ntohs(2)` / `ntohl(2)`
- `ntohs(2)` - 16ビットの符号なし整数をホストバイトオーダに変換する
- `ntohl(2)` - 32ビットの符号なし整数をホストバイトオーダに変換する

#### 引数
- `ntohs(2)` - `host_uint16`を指定する
  - `net_uint16` - 16ビットの符号なし整数
- `ntohl(2)` - `host_uint32`を指定する
  - `net_uint32` - 32ビットの符号なし整数

#### 返り値
- それぞれの引数をホストバイトオーダに変換した値

### `inet_pton(3)` / `inet_ntop(3)`
- `inet_pton(3)` - バイナリ形式のIPv4・IPv6アドレスを可読形式へ変換
- `inet_ntop(3)` - バイナリ形式のIPv4・IPv6アドレスを10進表現・16進表現へ変換

#### 引数
- `inet_pton(3)` - `domain`、`*src_str`、`*addrptr`を指定する
  - `domain` - `AF_INET` / `AF_INET6`
  - `*src_str` - 可読形式のIPアドレス
  - `*addrptr` - 変換後のアドレスを格納する`void`型の構造体へのポインタ
- `inet_ntop(3)` - `domain`、`*addrptr`、`*dst_str`、`len`を指定する
  - `domain` - `AF_INET` / `AF_INET6`
  - `*addrptr` - `in_addr` / `in6_addr`型の構造体へのポインタ
  - `*dst_str` - 変換後のアドレスを格納する文字列へのポインタ
  - `len` - `dst_str`のサイズ

#### 返り値
- `inet_pton(2)` - 数値1を返す
  - `*src_str`が解釈不能な場合は数値0を返す
  - エラー時は数値-1を返す
- `inet_ntop(2)` - `*dst_str`のポインタを返す
  - エラー時はNULLを返す

### `getaddrinfo(3)`
- 指定のホスト名・サービス名をIPアドレス・ポート番号へ変換し、
  ホスト・サービスに対応するソケットアドレス構造体のリンクリストを返す
  - アドレス構造体リストの全要素はダイナミックにメモリを割り当てられる

#### 引数
- `*host`、`*service`、`*hints`、`**result`を指定する
  - `*host` - 指定のホスト名または10進数 / 16進数のアドレスを示す文字列へのポインタ
  - `*service` - 指定のサービス名またはポート番号を示す文字列へのポインタ
  - `*hints` - `result`へ返すソケットアドレス構造体を絞り込む条件を表す`addrinfo`構造体へのポインタ
    - `hints.ai_flags` - `getaddrinfo(3)`の動作を操作する入力フラグ(ビットマスク)を指定する
  - `**result` - 内部でダイナミックに割り当てた`addrinfo`構造体のリストの先頭アドレスへのポインタ

```c
#include <sys/socket.h>
#include <netdb.h>

struct addrinfo {
  int              ai_flags;     // 入力フラグ
  int              ai_family;    // AF_INET / AF_INET6
  int              ai_socktype;  // SOCK_STREAM / SOCK_DGRAM
  int              ai_protocol;  // ソケットプロトコル
  socklen_t        ai_addrlen;   // ai_addrが指す構造体のサイズ
  char            *ai_canonname; // 正式ホスト名
  struct sockaddr *ai_addr;      // ソケットアドレス構造体へのポインタ
  struct addrinfo *ai_next;      // リスト内の次の要素へのポインタ
};
```

#### 返り値
- 数値0を返す
  - 数値0以外を返す

### `freeaddrinfo(3)`
- リスト内のアドレス構造体のメモリを一度に解放する

#### 引数
- `*result`を指定する

### `gai_strerror(3)`
- `getaddrinfo(3)`が返すエラーコードを表現する文字列を取得する

#### 引数
- `errcode`を指定する
  - `errcode` - `getaddrinfo(3)`が返すエラーコードを示す数値

#### 返り値
- エラー説明文字列へのポインタを返す

### `getnameinfo(3)`
- 指定されたソケットアドレス構造体をホスト名・サービス名へ変換する

#### 引数
- `*addr`、`addrlen`、`*host`、`hostlen`、`*service`、`servlen`、`flags`を指定する
  - `*addr` - 変換するソケットアドレス構造体へのポインタ
  - `addrlen` - ソケットアドレス構造体のサイズ
  - `*host` - 変換結果のホスト名を格納する文字列へのポインタ
  - `hostlen` - `host`のサイズ
  - `*service` - 変換結果のサービス名を格納する文字列へのポインタ
  - `servlen` - `service`のサイズ
  - `flags` - `getnameinfo(2)`の動作を操作する入力フラグ(ビットマスク)

#### 返り値
- 数値0を返す
  - 数値0以外を返す
