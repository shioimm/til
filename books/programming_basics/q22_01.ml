(* 問題22_1 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：文字列に毎回、異なる数字をつけて返す *)
(* gensym : string -> string *)

let count = ref (-1)

let gensym str =
  count := !count + 1;
  str ^ string_of_int !count

(* test *)
let test1 = gensym "a" = "a0"
let test2 = gensym "a" = "a1"
let test3 = gensym "x" = "x2"
