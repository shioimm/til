# gemの作り方
1. 環境を整える
    - `$ bundle gem toycol --test=minitest --ci=github`
    - コミット不要なファイルを.gitignoreへ追加
    - gemspecを整える
    - 不要なテストを削除
    - Rubocopを追加
    - CI環境を微調整
    - READMEを
2. 0.0.1をリリース
3. プロダクションコードを書き始める
   - minitest
4. 機能追加のきりの良いタイミングでマイナーバージョンアップ
5. READMEとCHANGELOGを更新
6. メジャーバージョンをリリース

### 追加した機能
- Protocol
- Proxy
- Rack handler
- Safe Execution
- Client
- CLI for client
- Builtin server
- CLI for server
- Template Generator
- CLI for generator
