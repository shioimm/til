# MIME
- Multiple Internet Mail Extensions
- データ形式をインターネット(電子メール、WWW、NetNews)で幅広く使えるように拡張するプロトコル
- OSI参照モデルにおいてはプレゼンテーション層に該当する

#### 基本構成
- MIMEヘッダ + 空行 + 本文

#### 複数コンテンツの指定
- アプリケーションヘッダのContent-Typeに`Multipart/Mixed`を指定し、
  `boundary=`オプションに区切り文字を指定する
- 空行 + `--区切り文字`で仕切った各区間に指定したいMIMEヘッダと本文を置く

## 参照
- マスタリングTCP/IP 入門編
