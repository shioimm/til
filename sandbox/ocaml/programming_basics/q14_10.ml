(* 問題14-10 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：受け取ったリストの中から偶数のみを抜き出したリストを返す *)
(* even : int list -> int *)
let even lst =
  List.filter (fun n -> n mod 2 = 0) lst

(* test *)
let test1 = even [] = []
let test2 = even [3] = []
let test3 = even [2] = [2]
let test4 = even [2; 1; 6; 4; 7] = [2; 6; 4]
let test5 = even [1; 2; 6; 4; 7] = [2; 6; 4]

(* 目的：リスト中の文字列をつなげた文字列を返す *)
(* concat : string list -> string *)

let concat lst =
  List.fold_right (fun first rest_result -> first ^ rest_result) lst ""

(* test *)
let test1 = concat [] = ""
let test2 = concat ["春"] = "春"
let test3 = concat ["春"; "夏"; "秋"; "冬"] = "春夏秋冬"
