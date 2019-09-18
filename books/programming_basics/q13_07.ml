(* 問題13-7 from 浅井健一 著「プログラミングの基礎」 *)

#use "q13_06.ml"

(* 目的：未確定の駅のリスト v を必要に応じて更新したリストを返す *)
(* update_list : station_t -> station_t list -> station_t list *)

let update_list p v =
  let f q = update p q in
  List.map f v

let station1 = {name="池袋"; shortest_distance = infinity; pre_list = []}
let station2 = {name="新大塚"; shortest_distance = 1.2; pre_list = ["新大塚"; "茗荷谷"]}
let station3 = {name="茗荷谷"; shortest_distance = 0.; pre_list = ["茗荷谷"]}
let station4 = {name="後楽園"; shortest_distance = infinity; pre_list = []}

let lst = [station1; station2; station3; station4]

(* test *)
let test1 = update_list station2 [] = []
let test2 = update_list station2 lst =
 [{name="池袋"; shortest_distance = 3.0; pre_list = ["池袋"; "新大塚"; "茗荷谷"]};
  station2; station3; station4]
