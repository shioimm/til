(* 問題9-6 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 受け取ったリストから文字列を前から順に連結して返す *)
(* concat : string list -> string *)
let rec concat lst = match lst with
  [] -> ""
  | first :: rest -> first ^ concat rest

(* test *)
let test1 = concat ["春"; "夏"; "秋"; "冬"] = "春夏秋冬"
let test2 = concat ["It's "; "OK."] = "It's OK."
let test2 = concat ["プログラミング"; "の"; "基礎"] = "プログラミングの基礎"
