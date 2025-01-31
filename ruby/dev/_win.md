# Windows環境での開発
- MSYS2 (Minimal System 2) - Windows上でUnixライクな環境を提供するツールセット
- MinGW (Minimalist GNU for Windows) - Windows上でネイティブなWindowsバイナリをコンパイルできるGCC環境
  - mingw64 - `x86_64`Windows用コンパイル環境 (`mingw-w64-x86_64-*`パッケージ使用)
  - mingw32 - `x86_32`Windows用コンパイル環境 (`mingw-w64-i686-*`パッケージ使用)
  - ucrt64 - UCRTベースの`x86_64`Windows用コンパイル環境 (`mingw-w64-ucrt-x86_64-*`パッケージ使用)
    - UCRT - Universal C Runtime
- pacman - MSYS2で使用されるパッケージ管理ツール
