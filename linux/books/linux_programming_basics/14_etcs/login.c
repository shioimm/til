// 引用: ふつうのLinuxプログラミング
// 第14章 プロセスの環境 7

// ログイン時の挙動
//   1. sytemdが端末の数だけfork()しgettyコマンドを起動
//   2. gettyが端末をopen()し、read()する
//      -> gettyが端末からのユーザー名が入力されるのを待つ
//      -> gettyがdup()を利用してFDの0番、1番、2番を端末につなぐ
//      -> gettyがloginをexec
//   3. loginがPAM(Pluggable Authentication Module)のユーザー認証用APIを呼び、認証を行う
//      (PAM - Pluggable Authentication Module 共有ライブラリ)
//   4. loginがシェルをexec
//      execl("bin/sh", "-sh", ...)

// $ w
//   ログインの記録を表示(/var/run/utmp)
