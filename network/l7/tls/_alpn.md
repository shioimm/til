# ALPN (Application-Layer Protocol Negotiation)
- TLSの拡張機能
- TLS上でクライアントとサーバがアプリケーションプロトコルをネゴシエーションするためのプロトコル
- TLSハンドシェイクの一部として行われ、接続を確立する前にどのプロトコルが使用されるかを決定する
  - クライアントがClientHelloのExtensionを利用して使用可能なプロトコルをサーバに送り、
    サーバがServerHelloのExtensionを利用して実際に使用するプロトコルをクライアントに返す
