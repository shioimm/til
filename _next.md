# Next.js
### プロジェクトディレクトリ構成
- `node_modules/`
- `pages/`
  - ` _app.tsx` (全ページに共通する処理をページ初期化時に追加する)
  - `api/` (Web API定義)
  - `*.tsx` (コンポーネント)
- `public/` (静的ファイル)
- `styles/`
  - `globals.css` (全体のスタイリング)
  - `*.module.css` (コンポーネント単位)
- `package.json`
- `package-lock.json`

### データ取得
- 実装する関数・関数の返す値によって、pagesのレンダリング手法が切り替わる

| 実装する関数 (exportする必要あり) | レンダリング手法 | 実行タイミング              |
| -                                 | -                | -                           |
| getStaticProps                    | SSG              | ビルド時 (SSG)              |
| revalidateを返すgetStaticProps    | ISR              | ビルド時 (ISR)              |
| getServerSideProps                | SSR              | リクエスト時 (サーバー)     |
| 上記以外                          | CSR              | リクエスト時 (クライアント) |

## プロジェクト開始時にやること (例)
1. プロジェクト作成 (`$ create-next-app`)
2. tsconfig.jsonの設定
3. CSSの導入 (styled-components)
4. リンタの導入 (ESLintの設定)
5. Storybookの導入・設定
6. 環境変数の設定 (.envファイル)
7. テスト環境の構築 (testing-library)
