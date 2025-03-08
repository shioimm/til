# エコシステム
### 言語仕様
- ECMAScript
- TypeScript (型システム拡張)

### 実行環境
#### クライアント (ブラウザ環境)

| JavaScriptエンジン | レンダリングエンジン | 主な対応ブラウザ           |
| -                  | -                    |  -                         |
| V8                 | Blink                | Chrome, Edge, Opera, Brave |
| SpiderMonkey       | Gecko                | Firefox                    |
| JavaScriptCore     | WebKit               | Safari                     |

#### サーバ (ランタイム環境)
| JavaScriptエンジン | ランタイム環境 |
| -                  | -              |
| V8                 | Node           |
| V8                 | Deno           |
| JavaScriptCore     | Bun            |

### パッケージマネージャ (ライブラリの依存関係の管理)
- npm
- yarn
- pnpm (軽量で高速なnpm代替)
- bun (Bunに統合されたパッケージマネージャ)

### モジュールバンドラ (JSファイルの結合)
- webpack
- rollup
- esbuild (軽量で高速なJavaScriptバンドラ)
- Vite (高速な開発サーバー・ビルドツール、esbuildベース)
- Bun (バンドル機能を内蔵)

### 開発サーバ (HMR開発環境)
- Vite
- webpack-dev-server

### トランスパイラ (ソースコードの変換: 新しい構文をサポート)
- Babel
- swc (Rust製)
- tsc

### フレームワーク・ライブラリ
- React
- Vue
- Svelte
- SolidJS

### CSS設計・スタイリングツール
- Tailwind CSS
- Styled Components
- Emotion
- PostCSS

### Polyfil (ブラウザに機能を追加する: 新しい関数の追加)
- core-js
- regenerator-runtime
- Babel

### テスト・テストランナー
- Jest (テストフレームワーク)
- Vitest (Viteベースのテスト環境)
- Testing Library (React/Vueなどのテストライブラリ)
- Playwright (ブラウザE2Eテスト)
- Cypress (ブラウザE2Eテスト)

### コードフォーマッタ・リンタ
- Prettier (コードフォーマッタ)
- ESLint (リンタ)
- Rome

### Gitフック
- husky
- lint-staged
- commitlint

## 参照
- [TypeScriptとエコシステム](https://typescriptbook.jp/overview/ecosystem)
