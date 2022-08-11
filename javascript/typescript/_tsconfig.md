# tsconfig.json
- TypeScriptプロジェクトの設定を記述する
  - ルートファイル
  - プロジェクトをコンパイルする際に必要なコンパイラのオプション

```json
{
    "compilerOptions": {
      // ...
    },
    "files": [
      // ...
    ],
    "include": [
      // ...
    ],
    "exclude": [
      // ...
    ]
}
```

- include
  - TSCがTSソースを見つけるためにどのディレクトリを探索するべきか
- lib
  - コードを実行する環境においてどのAPIが存在しているとTSCが想定するべきか
- module
  - TSCがコードをどのモジュールシステム (CommonJS、SystemJS、ES2015 etc) にコンパイルするべきか
- outDir
  - TSCは生成されるJSソースをどのディレクトリに格納するべきか
- strict
  - 厳密な型チェックを行うか
- target
  - TSCがコードをどのJSバージョン (ES3、ES5、ES2015、ES2016 etc) にコンパイルするべきか

## 参照
- プログラミングTypeScript
