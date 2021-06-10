# X.509証明書
- 公開鍵証明書の標準フォーマット

## X.509v3証明書の標準フォーマット
- TbsCertificate(証明前証明書)
  - Version(バージョン) - 証明書のバージョン
  - Serial Number(シリアル番号) - 証明書を一意に識別するために発行者が割り当てる番号
  - Signature(アルゴリズム識別子) - 発行者が署名をする際に用いるアルゴリズム
  - Issuer(発行者) - 証明書を発行した主体の識別名(DN: Distinguished Name)
  - Validity(有効性) - 有効期限(開始日・終了日の組み)
  - Subject(主体者) - 証明書の発行を受けた主体の識別名(DN: Distinguished Name)
    - 現在はSubjectの代わりにSAN(Subject Alternative Name)拡張が使用される
  - SubjectPublicKeyInfo(主体者公開鍵情報) - 主体者の公開鍵に関する情報
    - 暗号化アルゴリズムと公開鍵のビット列
  - IssuerUniqueID(発行者ユニーク識別子) - 使用しない
  - SubjectUniqueID(主体者ユニーク識別子) - 使用しない
  - Extensions(拡張領域)
- Signature Algorithm(署名アルゴリズム) - 署名前証明書に対する署名に利用されるアルゴリズム
- SignatureValue(署名値) - 署名アルゴリズムによって署名された値

### Extensions(拡張領域)
- 証明書のフォーマットに柔軟性を持たせるための機能
- 一意の識別子オブジェクト(OID:object identifier) + 拡張子の重要度(critical) + 値(ASN.1構造体)で構成される

#### Extensionsのフォーマット
- extnID(識別子) - 拡張の種別
- critical(重要度)
  - 真偽値
  - `critical`な拡張が処理できない場合、証明書は破棄される
- extnValue(拡張値) - 拡張子のデータ

#### 標準的な拡張
- Authority Key Identifier(機関鍵識別子)
  - 証明書の署名の検証に利用する公開鍵の識別子
  - 発行者が複数の署名鍵を持つ場合に使用
- Subject Key Identifier(サブジェクト鍵識別子)
  - 複数の証明書(公開鍵)から証明書(公開鍵)を一意に特定する
  - 発行者が複数の署名鍵を持つ場合に使用
- Key Usage(鍵用途)
  - 証明書に含まれる鍵の用途を規定する
- Certificate Policies(証明書ポリシー)
  - 証明書の利用目的に応じて設定するポリシー
- Policy Mapping(ポリシーマッピング)
  - 発行元のCAのポリシーにおいて受け入れ可能なポリシーの対応を示す
  - CAの証明書で使用
- Subject Alternative Name(主体者代替名)
  - Subjectとは異なる別名を指定する
- Issuer Alternative Name(発行者代替名)
  - Issuerとは異なる別名を指定する
- Subject Directory Attributes(サブジェクトディレクトリ属性)
  - Subjectの属性情報を伝えるために使用する
- Basic Constraints(基本制約)
  - SubjectがCAであるか否かを示す
  - この証明書を含めていくつ下位CAを持つことができるか(階層の深さ)を示す
- Name Constraints(名前制約)
  - この証明書の発行する証明書のSubjectおよびSubject Alternative Nameの名付け方を制約する
  - CAによって発行された証明書においてのみ使用される
- Policy Constraints(ポリシー制約)
  - この証明書tの発行する証明書のポリシーについて制約する
  - CAによって発行された証明書においてのみ使用される
- Extended Key Usage(鍵用途拡張)
  - Key Usageで設定された鍵の利用用途に加えて(or 代わりに)設定される
- CRL Distribution Points(CRL配布点)
  - CRL(Certificate Revocation List: 証明書失効リスト)の場所を示す
- Inhibit anyPolicy(anyPolicyの禁止)
  - 下位のCAが発行する証明書において、anyPolicyが何回受け入れられるかを示す
  - CAによって発行された証明書においてのみ使用される
- Freshest CRL(最新CRL)
  - delta CRL(証明書執行リストの差分)を配布している場所を示す
- Authority Information Access
  - 証明書を発行するCAが提供している付加的な情報やサービスへのアクセス方法を示す

## 参照
- マスタリングTCP/IP 情報セキュリティ編
