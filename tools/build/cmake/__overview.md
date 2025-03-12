# CMake
- 特定の環境用のビルドファイルを生成するビルドマネジメントツール
- 特定のコンパイラに依然せずクロスプラットフォームで動作する
- 設定ファイルCMakeLists.txtに従いプロジェクトをビルドする

#### 動作フロー
1. ビルド対象のソースコードの作成
2. CMakeLists.txtの作成
3. cmakeコマンドの実行 (`Configure` -> `Generate`)
    - Configure - CMakeにCMakeLists.txtを実行させ、ビルドに必要な情報を収集する
    - Generate - Configureで集めた情報を基に開発環境に合わせたプロジ  ェクトファイルを生成する
4. `cmake --build`コマンドの実行 (プロジェクトファイルを利用しプロジェクトをビルド)
    - ビルドツールの指定も可能 (e.g. Ninja)

## 参照
- [CMake](gitlab.kitware.com/cmake/cmake)
- [勝手に作るCMake入門 その1 基本的な使い方](https://kamino.hatenablog.com/entry/cmake_tutorial1)
