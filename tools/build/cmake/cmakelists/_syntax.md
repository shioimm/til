# 文法
## API
- `add_executable` - ビルドする実行ファイル名とそれを構成するソースファイルの指定
- `add_library` - ライブラリとして宣言
- `add_subdirectory` - プロジェクトのサブディレクトリの取り込み
- `cmake_minimum_required` - CMakeのバージョン指定
- `find_package` - 特定の名前のCMakeスクリプトを探し出し、それを実行する
- `message` - 標準出力するメッセージの設定
- `project` - プロジェクト名の宣言
- `set` - 値のセット
- `set_target_properties` - プロパティの設定
- `target_compile_features` - コンパイル時のプロパティの指定
- `target_include_directories` - インクルードディレクトリの指定
- `target_link_libraries` - 依存するライブラリの宣言
- `unset` - 値の取り消し

## 制御構文
```
if(条件式)
  処理
endif()
```

## 参照
- [勝手に作るCMake入門 その1 基本的な使い方](https://kamino.hatenablog.com/entry/cmake_tutorial1)
- [勝手に作るCMake入門 その2 プロジェクトの階層化](https://kamino.hatenablog.com/entry/cmake_tutorial2)
- [勝手に作るCMake入門 その3 プロジェクトの設定](https://kamino.hatenablog.com/entry/cmake_tutorial3)
- [勝手に作るCMake入門 その4 外部ライブラリを利用する](https://kamino.hatenablog.com/entry/cmake_tutorial4)
