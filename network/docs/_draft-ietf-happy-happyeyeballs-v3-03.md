# Happy Eyeballs Version 3: Better Connectivity Using Concurrency
https://datatracker.ietf.org/doc/draft-ietf-happy-happyeyeballs-v3/

## 1. Introduction
- 現代のインターネット上で動作する多くの通信プロトコルはホスト名を利用する
- これらのホスト名はしばしば複数のIPアドレスに名前解決され、それぞれが異なる性能特性や接続性の特性を持つ場合がある
- 特定のアドレスやアドレスファミリが、あるネットワーク上で遮断されていたり、故障していたり、
  最適ではない場合があるため、複数の接続を並行して試行するクライアントは、より迅速に接続を確立できる可能性がある
- 本書は、ユーザーに見える遅延を減らすためのアルゴリズムに対する要件を規定し、その一例となるアルゴリズムを提示する
- 本書で、デュアルスタックホストにおいてユーザーに見える遅延を減らす技術であるHappy Eyeballsのアルゴリズムを定義する
- Happy Eyeballsアルゴリズムは、名前解決されたアドレス群に対して接続試行を競争的に行う方式であり、
  可能な限りユーザーへの遅延を回避しつつ、IPv6の優先利用や、HTTP/3、TLS Encrypted Client Hello (ECH) のような
  プロトコルの利用可能性といったクライアント側の優先順位を尊重するため、いくつかの段階で構成されている
  - 本書では接続開始時にDNS問い合わせをどのように開始するか、
    DNS応答で得られた宛先アドレス一覧をどのように並べ替えるか、接続試行をどのように競争させるかについて論じる
- HEV2との主な違いは、SVCB / HTTPS Resource Records への対応が追加された点である
  - SVCBレコードは代替エンドポイント、アプリケーションプロトコル対応状況、Encrypted Client Hello (ECH) 鍵、
    アドレスヒント、アクセス対象サービスに関するその他の関連情報を提供する
- 名前解決中に (たとえばQUIC上のHTTP/3などの) プロトコルの対応状況を検出することにより、
  HTTP Alternative Services (Alt-Svc) など別の発見メカニズムから得た情報を利用して次回以降の接続試行を行うのではなく
  現在進行中の接続試行の段階でプロトコルをアップグレードできる
- これらのレコードはA / AAAAレコードとあわせて照会することができ、
  更新後のアルゴリズムでは接続確立を改善するためにSVCB応答をどのように扱うかを定義する

## 2. Conventions and Definitions
- MUST / REQUIRED / SHALL しなければならない
- MUST NOT / SHALL NOT してはならない
- SHOULD / RECOMMENDED する必要がある
- SHOULD NOT / NOT RECOMMENDED しないほうがよい
- MAY / OPTIONAL してもよい

## 3. Overview
- 本書は、Happy Eyeballs Connection Setupと呼ばれる接続確立方式を定義する

1. ホスト名を宛先アドレスへ非同期に名前解決する
2. 名前解決された宛先アドレスを並べ替える
3. 非同期の接続試行を開始する
4. 1つの接続を正常に確立し、その他の試行を取り消す

- 本書では、ホスト宛先アドレスに対する優先ポリシーがIPv4よりもIPv6を優先することを前提とする
- 本書では、優先ポリシーがTCPよりもQUIC を優先することも前提とする
- ホストが異なる優先設定となっている場合でも、本書の推奨事項は容易に適応できる

## 4. Hostname Resolution
- クライアントが名前付きホストへの接続を確立しようとする際、
  そのホストへ到達するために利用可能な宛先IPアドレスを判断する必要がある
- クライアントはDNS問い合わせを送信し、その応答を収集することで、ホスト名をIPアドレスへ名前解決する
- 本節ではクライアントがどのようにDNS問い合わせを開始し、その応答を非同期に処理するかについて論じる

### 4.1. Sending DNS Queries
- クライアントはまず、名前付きホストに対する問い合わせに、どのDNSリソースレコードを含めるかを判断する必要がある
  - この判断は、クライアントがIPv4およびIPv6の接続性を有しているかどうかに基づく
    - 接続性を有しているかどうか: そのアドレスファミリに属するローカルアドレスを少なくとも1つ持ち、
      かつ、そのアドレスファミリに対するリンクローカルではない経路を少なくとも1つ持つこと
- クライアントがIPv4とIPv6の両方の接続性を持つ場合、AAAAレコード / Aレコード両方の問い合わせを送信する必要がある
  - IPv4接続性のみを持つネットワークでは、Aレコードへの問い合わせを送信する
  - IPv6接続性のみを持つネットワークでは、ネットワーク構成に応じてAAAAレコード / Aレコード両方を問い合わせるか、
    AAAAレコードのみに問い合わせる
  - IPv6-mostlyおよびIPv6-only ネットワークの扱いについてはSupporting IPv6-Mostly and IPv6-Only Networksを参照
- AAAAレコード / Aレコードの要求に加え、どのアプリケーションが接続を確立しようとしているかに応じて、
  クライアントはSVCBレコードまたはHTTPSレコード(SVCB / HTTPS Resource Records) を要求できる
  - [SHOULD] HTTPまたはHTTPSを利用するアプリケーションの場合、クライアントはHTTPSレコードを問い合わせるべき
- [SHOULD] すべてのDNS問い合わせは、可能な限り互いに近いタイミングで行うべき
- [SHOULD] 問い合わせの送信順序は、上記の条件により不要なものを省いたうえで、以下の順序とするべき:
  - 1. SVCBまたはHTTPSへの問い合わせ
  - 2. AAAAへの問い合わせ
  - 3. Aへの問い合わせ

### 4.2. Handling DNS Answers Asynchronously
- クライアントは、DNS問い合わせに対して十分な応答を受信した時点で、
  アドレスの並べ替えおよび接続確立の段階へ進むことができる
- [SHOULD NOT] 実装はすべての応答を待ってから次の接続確立手順を開始するべきではない
  - ある問い合わせが失敗したり著しく遅れて返ってきたりする場合、
    すでに受信済みの応答だけで進行可能であった接続確立が、大きく遅延する可能性があるため
  - [SHOULD] クライアントはDNS名前解決を非同期処理として扱い、異なるレコード種別を独立して処理するべき
    - プラットフォームが非同期DNS APIを提供していない場合でも、
      各レコード種別について個別の同期問い合わせを並列実行することで、この動作を模擬できる
- クライアントは、以下のいずれかの条件群を満たした時点で、アドレスの並べ替えおよび接続確立へ進む

```
条件1
何らかの肯定的 (空でない) アドレス応答を受信している
&& 問い合わせ対象であった優先アドレスファミリについて肯定的 (空でない) または否定的 (空の) 応答を受信している
&& SVCB / HTTPS のサービス情報を受信している (または否定的応答を受信している)
```

```
条件2
何らかの肯定的 (空でない) アドレス応答を受信している
&& 他の応答が届かないまま、名前解決待機時間が経過している
```

- 肯定的応答: AAAA / Aレコードから得られたアドレス、またはSVCB / HTTPSレコードに含まれるaddress hintsによるアドレス
- 否定的応答: AAAA / A レコードに対する応答で、アドレスを含まないもの
  - NXDOMAIN (DNSサーバが検索されたドメイン名が存在しない) のようなエラーを伴う場合も、伴わない場合も含む
  - すべての応答が否定的応答であった場合、接続確立は失敗するか、別の応答が届くまで待機する必要がある
- IPv6およびIPv4の両方にデフォルトルートが存在するネットワークでは、IPv6が優先アドレスファミリであるとみなされる
- IPv6またはIPv4のどちらか一方にのみデフォルトルートが存在するネットワークでは、
  そのアドレスファミリを、アルゴリズム進行上の優先アドレスファミリとみなす
- Resolution Delayは、優先アドレス (AAAAレコード経由) およびサービス情報 (SVCB / HTTPS レコード経由) を
  受信する機会を与えるための短い待機時間
  - Resolution Delayは、AAAAレコードまたはSVCB / HTTPSレコードが、Aレコードより遅れて到着する場合を考慮したもの
  - Resolution Delay の推奨値は50ミリ秒

#### 4.2.1. Resolving SVCB/HTTPS Aliases and Targets
- SVCB / HTTPSレコードは、ネットワークサービスに関する情報を記述する
  - 個々のレコードはAliasModeまたはServiceModeのいずれか
    - AliasModeの場合、別名先の名前に対してさらにSVCB / HTTPS問い合わせを行う必要がある
    - ServiceModeの場合、元の問い合わせ名に対応する場合があり、その場合のTargetNameは `"."`
      - 別のサービス名に対応する場合もある ([SVCB / HTTPS Resource Records])
  - HEv3では、ServiceModeレコードが利用可能になるまで、サービス情報を受信したとはみなさない
  - ServiceModeレコードは`ipv6hint`および`ipv4hint`パラメータによってアドレスヒントを含むことがある
    - [SHOULD] これらを受信した場合、対応するTargetNameのA / AAAAレコードがまだ利用可能でないときは、
      アルゴリズム上、肯定的かつ空でない応答として扱うべき (shioimm: 利用可能でない = 応答を受信していない)
      - クライアントはそれらのTargetNameに対するA / AAAA問い合わせの応答を受信していない限り、
        引き続きA / AAAA問い合わせを送信する必要がある
        - 実際のA / AAAA問い合わせの応答を受信した時点でヒントは実際のレコードに置き換えられ、
          新たな応答として利用可能な応答集合が更新される

#### 4.2.2. Examples
TODO: 各種シナリオの例を示すこと

- 単純なデュアルスタック環境
- SVCB利用時
- AAAA応答が遅延する場合
- SVCB応答が遅延する場合
- SVCBヒントによって早期に応答が得られる場合

### 4.3. Handling New Answers
- 接続試行が進行中であり、まだいずれの接続も確立していない間に新しいレコードが到着した場合、
  新たに受信したアドレスは、利用可能な候補アドレス一覧に組み込まれる
  - 1つの接続が確立されるまで、新しいアドレスを追加した状態で接続試行処理を継続する

### 4.4. Handling Multiple DNS Server Addresses
- 現在のネットワークに複数のDNSサーバアドレスが設定されている場合、
  クライアントはDNS問い合わせをIPv4 / IPv6のいずれかで送信できる場合がある
- [SHOULD] Happy Eyeballsの考え方に従い、問い合わせはまずIPv6上で送信するべき
  - これはAAAA問い合わせやA問い合わせの種類ではなく、
    DNSサーバ自身のアドレスおよびDNSメッセージ輸送に用いるIPバージョンを指す
- IPv6アドレス宛てに送信したDNS問い合わせに応答が返らない場合、そのアドレスにはペナルティを与えたものとして扱い、
  他のDNSサーバアドレスへ問い合わせを送信してもよい
- ネイティブIPv6展開がより一般的になり、IPv4アドレスが枯渇していくにつれて、
  ネットワーク内ではIPv6接続性が優先的に扱われることが想定される
- DNSサーバがIPv6経由で到達可能なよう設定されている場合、IPv6を優先アドレスファミリとみなすべき
- [SHOULD NOT] クライアントシステムは、手動設定であってもネットワークから配布された設定であっても、
  設定可能なDNSサーバ数に明示的な上限を設けるべきではない
  - [SHOULD] ハードウェア上の制約によりそのような上限が必要な場合でも、
    クライアントは利用可能な一覧の中から、各アドレスファミリごとに少なくとも1つのアドレスを使用するべき

## 5. Grouping and Sorting Addresses
- 名前解決された宛先アドレスのいずれかに接続を試みる前に、
  クライアントはどの順序で接続試行を開始するかを決定する
- 順序が定義された後、クライアントは短い遅延を挟みながら各候補を競争的に試行する単純なアルゴリズムを使用できる
- この時点までに受信した両方のアドレスファミリのすべてのアドレスと、すべてのプロトコルを含んだ順序付き一覧とすること
  - そうすることで、最初のIPv4アドレスと最初のIPv6アドレスだけでなく、
    一覧全体に対してHappy Eyeballsの競争効果を得ることができる
- クライアントは受信したDNS応答に基づき、アドレスに対して3段階のグループ化および並べ替えを行う
  - 1. アプリケーションプロトコルおよびセキュリティ要件によるグループ化・並べ替え
  - 2. サービス優先度によるグループ化・並べ替え
  - 3. 宛先アドレスの優先設定による並べ替え
  - 後続の各段階では、それ以前の段階で定義されたグループ内部における順序や優先度のみを変更する

### (shioimm)
1. (5.1) アプリケーションプロトコル・セキュリティ要件でグループ化 (グループ自体のソートは実装依存)
    - アプリケーションにとって本当に意味のある差異があるときだけグループを分ける必要がある
2. (5.2) サービス優先度でグループ化
    - SVCBがある場合: サービスごとにグループ化し、優先度の数値が小さい順に並べる
    - 同優先度が複数ある場合: ランダムシャッフル
    - SVCBがない / 全部同じ場合: 全部1グループ
    - 紐付かないA / AAAAの場合: 末尾グループ
3. (5.3) グループ内の宛先アドレスをソート
    - グループ内での並び替えルールはv2と同じ

### 5.1. Grouping By Application Protocols and Security Requirements
- クライアントは、宛先エンドポイントがどのアプリケーションプロトコルをサポートしているか、
  どのセキュリティ機能を提供しているかに基づいてグループ化を行う
  - これらの情報はSVCB / HTTPSレコードに含まれるアプリケーション層プロトコル情報 (`alpn`値) や、
    TLS Encrypted Client Hello 設定 (`ech`値 [SVCB-ECH]) などの各種パラメータに基づく
    - 応答にSVCB / HTTPS情報が含まれない場合、またはすべての応答が同一のSVCB / HTTPSレコードに対応している場合、
      すべての応答は1つのグループに属し、クライアントはそれらが同じプロトコル・同じセキュリティ特性を持つとみなす
    - 複数の異なるSVCB / HTTPSレコードを受信した場合、
      クライアントは異なる能力を広告する複数の宛先エンドポイント集合を認識する
      - [SHOULD] クライアントは、同一グループ内のすべてのアドレスが、
        同じアプリケーションプロトコルおよび関連するセキュリティ特性を共有するように、
        それぞれ別グループへ分離するべき
- クライアントにとって重要なパラメータはクライアント実装およびアプリケーションによって異なる
- 一部の宛先アドレスが複数グループに属する必要がある場合がある

```text
e.g.
example.com. 60 IN HTTPS 1 svc1.example.com. (alpn="h3,h2" ipv6hint=2001:db8::2)
example.com. 60 IN HTTPS 1 svc2.example.com. (alpn="h2"    ipv6hint=2001:db8::4)

- 2001:db8::2はHTTP/3とHTTP/2の両方に使用できる
- 2001:db8::4はHTTP/2にのみ使用できる

クライアントが HTTP/3対応アドレス群 と HTTP/2対応アドレス群 でグループ化する場合、
2001:db8::2は両方のグループに含まれる (他のセキュリティ特性がすべて同じであると仮定した場合)
```

- Connection racingは、各グループ内にある複数の宛先アドレス候補に対して適用される
- 異なるセキュリティ特性やプロトコル特性を持つグループ間で、どのように優先順位付けやフォールバックを行うかは実装依存

#### 5.1.1. When to Apply Application Preferences (グループ化を適用するべき条件)
- 特定のアプリケーションプロトコルやセキュリティ機能を別グループとして扱うかどうかは、
  クライアントアプリケーション側の判断
  - [SHOULD] クライアントはそのアプリケーションプロトコルや機能の利用が重要でない場合、
    別個にグループ化・並べ替えを行うことを避けるべき
  - e.g.
    - 単純なWebページを読み込むHTTPクライアントでは、HTTP/3とHTTP/2のどちらを使っても大きな差がない可能性がある
      そのため、ALPNを同一グループにまとめHTTP/3をHTTP/2より後順位に置くなど、サービス側で定めた優先順位を尊重できる
    - 別のクライアントは、HTTP/3が持つunreliable frames送信機能により、
      そのアプリケーション用途で大きな性能向上が得られる可能性がある
      その場合、HTTP/3をHTTP/2より優先する形で別グループ化することがある
    - あるアプリケーションでは、プライバシーに敏感な通信のためにTLS ECHの利用を必須または強く優先する場合があるが、
      別のアプリケーションではECHを機会的に利用するだけである可能性もある
    - ECH設定を含む応答と含まない応答が混在するSVCBレコード集合はSVCB-ECHでは推奨されないが起こりうる
      - 後者を高順位、前者を後順位に置く構成もあり得る (実験導入や段階的ロールアウト戦略のため)
      - クライアントはECH情報を利用しない場合や、その接続でECH利用による利点がない場合には、
        ECHを含む応答を機械的に別グループ化して先頭に並べるべきではない
        - [MAY] アプリケーション側にECHを優先する合理的理由がある場合、
          クライアントはそれらの応答を別グループとして扱い、優先してもよい
          - それが公開されているサービスレコードの優先順位と衝突するとしても、
            サービスが公開した応答はすべてクライアントによる利用対象であり、
            クライアントはそれらを使用するかどうかを選択できる

### 5.2. Grouping By Service Priority
- アプリケーションプロトコルやセキュリティ要件でアドレスをグループ化 (5.1) したあと、
  SVCB/HTTPSレコードで定義された異なるサービス間でグループ化を行い、これらのグループを優先度で並び替える
  - この段階により、サーバ側が公開した優先順位をクライアントの接続確立アルゴリズムへ反映できる
  - SVCBレコードは、各ServiceMode応答に対して優先度が示される
    - 優先度は、そのレコード自体に含まれるIPv4 / IPv6 address hintsに加え、
      ServiceModeレコード内の名前に対するA / AAAA問い合わせで得られたアドレスにも適用される
      - SVCB ServiceMode レコードにおける優先度は、常に0より大きい
      - 数値として最も小さいSVCB応答 (1など) を先に並べ、より大きい数値の応答を後ろに並べる
  - TargetNameが`"."`のSVCBレコードはそのレコードのowner nameに適用され、
    そのSVCBレコードの優先度は、同じowner nameに対するA / AAAAレコードにも適用される
    - これらの応答は、そのSVCBレコードの優先度に従って並べ替えられる
  - [SHOULD] 特定のSVCBサービスから受信したすべてのアドレスは、
    関連付けられたAAAAレコード、Aレコード、またはaddress hintsによって、グループに分割されるべき
    - [SHOULD] そのうえで、これらのサービス単位のグループは、サービス優先度を用いて並べ替えられるべき
- 応答にSVCB / HTTPS情報が含まれない場合、あるいはすべての応答が同一のSVCB / HTTPSレコードに対応している場合:
  - すべての応答は同じ優先度を持つ1つのグループに属する
- [SHOULD] 同じ優先度を持つサービス、つまり複数のグループが存在する場合、
  クライアントはこれらのグループをランダムにシャッフルするべき
- [SHOULD] 一部のSVCB / HTTPS サービス情報は受信しているものの、
  対応するサービスに紐付かないAAAA / Aレコードが存在する場合
  (e.g. 元の名前に対してTargetName `"."` のSVCB / HTTPSレコードが受信されなかった場合)
  それらの未関連アドレスは、一覧の末尾に優先されるグループとして配置されるべき

```text
example.com. IN HTTPS 1 svc1.example.com. (alpn="h3,h2")
example.com. IN HTTPS 2 svc2.example.com. (alpn="h2")

svc1.example.com. IN AAAA 2001:db8::1   <- svc1に紐付いたAAAAレコード (SVCBの優先度でグループ化)
svc2.example.com. IN AAAA 2001:db8::2   <- svc2に紐付いたAAAAレコード (SVCBの優先度でグループ化)
example.com.      IN AAAA 2001:db8::99  <- どのSVCBにも紐付かないAAAAレコード (末尾に低優先度グループとして追加)
example.com.      IN A    192.0.2.1     <- どのSVCBにも紐付かないAレコード (末尾に低優先度グループとして追加)
```

### 5.3. Sorting Destination Addresses Within Groups
- 各アドレスグループ内でサービスに基づくグループ化 (5.2) を行った後、
  クライアントは優先度および過去の履歴データに基づいてアドレスを並べ替える
  - [MUST] クライアントは宛先アドレス選択 (Destination Address Selection) を用いてアドレスを並べ替えなければならない
    ([RFC 6724])
    - [SHOULD] クライアントが状態を保持しており、
      各アドレスへ到達する経路について想定往復時間 (RTT) の履歴を持っている場合、
      ルール8とルール9の間に、RTT が低いアドレスを優先するルールを追加するべき
    - [SHOULD] 過去に使用したアドレスを追跡している場合、そのRTTルールとルール9の間に、
      未使用アドレスより使用済みアドレスを優先する別のルールを追加するべき
      - これはTCP Fast Openや一部のHTTP Cookieのように、クライアントのIPアドレスを認証に利用するサーバに有効
      - [MUST] 履歴データは、当該エンドポイントに関するプライバシー上機微な情報と同じ境界で分離しなければならない
        - [MUST NOT] 異なるネットワークインターフェース間で共有してはならない
        - [SHOULD] 端末が接続先ネットワークを変更した場合、このデータは消去されるべき
          - [MAY] クライアントが以前接続していたネットワークを確実に識別できる場合、
            再接続時にそのネットワークに紐づく履歴データを保持し、再利用してもよい
        - [MUST] 履歴データを利用するクライアントは、異なる履歴を持つクライアント同士が
          最終的には同様の挙動へ収束することを保証しなければならない
          e.g. 定期的に履歴データを無視し、新しいアドレスへの接続試行を行うことで、それを実現できる
  - [SHOULD] クライアントは、アドレスファミリが交互になるように並び順を調整するべき
    - 一覧の先頭にあるアドレスファミリの次には、もう一方のアドレスファミリのエンドポイントが続くべき
      - e.g. 並べ替え後の一覧の先頭がIPv6 アドレスである場合、最初のIPv4アドレスは一覧の2番目へ繰り上げられるべき
      - [MAY] 実装によっては一方のアドレスファミリをより優遇し、次のアドレスファミリへ進む前に、
        そのアドレスファミリの複数アドレスを連続して試行するようにしてもよい
      - 先頭アドレスファミリに属する連続アドレス数はPreferred Address Family Countと呼ばれ、設定可能な値とできる
        - これはあるアドレスファミリの接続性が劣化している場合、
          そのアドレスファミリの長いアドレス一覧を順番に待たされることを防ぐため
- 本節で述べるアドレス選択は、宛先アドレスのみに適用される
  - 送信元アドレス選択 (Source Address Selection) は各宛先アドレスごとに実行されるものであり、
    本書の対象範囲外です ([RFC 6724 Update])

## 6. Connection Attempts
### 6.1. Determining successful connection establishment
### 6.2. Handling Application Layer Protocol Negotiation (ALPN)
### 6.3. Dropping or Pending Connection Attempts
## 7. DNS Answer Changes During Happy Eyeballs Connection Setup
## 8. Supporting IPv6-Mostly and IPv6-Only Networks
### 8.1. IPv4 Address Literals
### 8.2. Discovering and Utilizing PREF64
### 8.3. Supporting DNS64
### 8.4. Hostnames with Broken AAAA Records
### 8.5. Virtual Private Networks
## 9. Summary of Configurable Values

## 10. Limitations
- Happy Eyeballsは、トランスポート層 (TCPやQUIC) における初期接続失敗に対応できる
  - それ以外の障害や性能上の問題は、選択された接続に依然として影響を与える可能性がある

### 10.1. Path Maximum Transmission Unit Discovery
- TCPのみを使用する接続 (TLS他の上位プロトコルを使用しない場合) では、接続の競争はTCPハンドシェイク中にのみ行われる
  - そのような接続において、小さなパケットによるハンドシェイクは成功しても、
    ネットワーク上で小さなMTUが設定されている場合は
    大きなパケットが破棄されたり不適切に処理されたりする問題が発生する可能性がある
    - この種の問題は、ネットワーク上の IPv6 通信に限定して発生する場合もある
  - この問題はTLS利用時にも発生し得るが、多くのTLSハンドシェイクで使われる比較的大きなメッセージにより、
    最大サイズのTCP セグメントが配送可能であることを確認できる場合が多い
  - QUIC接続では少なくとも1200バイトの最小MTUが保証されている
    - それより大きな値が利用できない可能性はある
  - これらの問題の解決は本書の対象範囲外であり、提案される手法の一つとして
    Packetization Layer Path MTU Discoveryの利用がある

### 10.2. Application Layer
- DNSが複数のアプリケーションサーバに対応する複数アドレスを返した場合でも、
  アプリケーション自体がそのすべてのサーバ上で正常に稼働し、機能しているとは限らない
  - 一般的な例としてTLSやHTTPがある

### 10.3. Hiding Operational Issues
- Happy Eyeballsは実運用においてネットワーク上の問題を見えにくくしてしまうことがある
  - e.g. 設定ミスによって特定ネットワーク上でIPv6が継続的に失敗している一方IPv4 は正常に動作している場合、
    Happy Eyeballsによってその問題に気付きにくくなる可能性がある
- ネットワーク運用者は、すべてのアドレスファミリの機能性を確認するため、外部的な監視手段を導入することが推奨される

## 11. Security Considerations
- アプリケーションは、安定したホスト名からアドレスへの対応関係に依存し、
  何らかのセキュリティ特性を保証しようとするべきではない
  - DNSの結果は問い合わせのたびに変化する可能性があるため
  - Happy Eyeballsによって、同一ホスト名への後続接続が異なるIPアドレスを使用する可能性はより高くなる
- HTTPを利用する場合、HTTPSリソースレコードはクライアントがオリジンへ接続する際にHTTPSを必須とするべきことを示す
  - RFC 9460
  - 能動的攻撃者はHTTPSリソースレコードの正常な配信を妨害することで、ダウングレード攻撃を試みる可能性がある
- クライアントが安全でないDNSメカニズムを使用している場合、通信経路上の攻撃者がHTTPSリソースレコードを破棄しうる
  - クライアントはそれが攻撃によるものなのか、HTTPS問い合わせに応答しないリゾルバによるものなのかを区別できない
  - [MUST NOT] RFC 9460に記載されているような暗号学的に保護されたDNSメカニズムを使用する場合、
    SVCB-reliantクライアントおよびSVCB-optionalクライアントのいずれも有効なHTTPS 応答を受信していない限り、
    TCPハンドシェイク完了後に暗号化されていないデータを送信してはならない
  - HTTPS応答が否定的応答でない場合、これらのクライアントは先へ進む前にTLSハンドシェイクを完了する必要がある

## 12. IANA Considerations
- 本書は、IANAによるいかなる対応も要求しない

## 13. References
### 13.1. Normative References
- [ECH] "TLS Encrypted Client Hello"
- [RFC2119] "Key words for use in RFCs to Indicate Requirement Levels"
- [RFC4821] "Packetization Layer Path MTU Discovery"
- [RFC6052] "IPv6 Addressing of IPv4/IPv6 Translators"
- [RFC6146] "Stateful NAT64: Network Address and Protocol Translation from IPv6 Clients to IPv4 Servers"
- [RFC6147] "DNS64: DNS Extensions for Network Address Translation from IPv6 Clients to IPv4 Servers"
- [RFC6298] "Computing TCP's Retransmission Timer",
- [RFC6535] "Dual-Stack Hosts Using "Bump-in-the-Host" (BIH)"
- [RFC6724] "Default Address Selection for Internet Protocol Version 6 (IPv6)"
- [RFC6724-UPDATE] "Prioritizing known-local IPv6 ULAs through address selection policy"
- [RFC7050] "Discovery of the IPv6 Prefix Used for IPv6 Address Synthesis",
- [RFC8174] "Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words"
- [RFC8781] "Discovering PREF64 in Router Advertisements"
- [RFC9000] "QUIC: A UDP-Based Multiplexed and Secure Transport"
- [RFC9460] "Service Binding and Parameter Specification via the DNS (SVCB and HTTPS Resource Records)"
- [SVCB] "Service Binding and Parameter Specification via the DNS (SVCB and HTTPS Resource Records)"
- [SVCB-ECH] "Bootstrapping TLS Encrypted ClientHello with DNS Service Bindings"

### 13.2. Informative References
- [AltSvc] "HTTP Alternative Services"
- [DNSSEC] "DNS Security Extensions (DNSSEC)", BCP 237,
- [DOH] "DNS Queries over HTTPS (DoH)"
- [DOQ] "DNS over Dedicated QUIC Connections"
- [DOT] "Specification for DNS over Transport Layer Security (TLS)"
- [HEV2] "Happy Eyeballs Version 2: Better Connectivity Using Concurrency"
- [HTTP3] "HTTP/3"
- [I-D.ietf-tls-key-share-prediction] "TLS Key Share Prediction"
- [IPV6] "Internet Protocol, Version 6 (IPv6) Specification"
- [QUIC] "QUIC: A UDP-Based Multiplexed and Secure Transport"
- [RFC6555] "Happy Eyeballs: Success with Dual-Stack Hosts"
- [RFC6877] "464XLAT: Combination of Stateful and Stateless Translation"
- [RFC7413] "TCP Fast Open"
- [RFC8446] "The Transport Layer Security (TLS) Protocol Version 1.3"
- [RFC8765] "DNS Push Notifications",
- [RFC9001] "Using TLS to Secure QUIC"
- [RFC9002] "QUIC Loss Detection and Congestion Control"
- [V6-MOSTLY] "IPv6-Mostly Networks: Deployment and Operations Considerations"
