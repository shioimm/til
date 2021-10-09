(* 問題7-2 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 名前と評価の組を受け取り、「xさんの評価はyです」という文字列を返す *)
(* grades : (string, string) -> string *)

let grades pair = match pair with
  (name, result) -> name ^ "さんの評価は" ^ result ^ "です"

(* test *)
let test1 = grades ("tanaka", "A") = "tanakaさんの評価はAです"
let test2 = grades ("suzuki", "B") = "suzukiさんの評価はBです"
let test3 = grades ("sato", "C") = "satoさんの評価はCです"
