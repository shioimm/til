(* 問題14-9 from 浅井健一 著「プログラミングの基礎」 *)

#use "q08_03.ml"

fun person -> match person with
  {name=n; m=m; kg=kg; month=mon; date=dt; blood_type=bt;} -> n
