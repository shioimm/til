(* 問題13-6 from 浅井健一 著「プログラミングの基礎」 *)

#use "q10_11.ml"
#use "q12_01.ml"

let station1 = {name="池袋"; shortest_distance = infinity; pre_list = []}
let station2 = {name="新大塚"; shortest_distance = 1.2; pre_list = ["新大塚"; "茗荷谷"]}
let station3 = {name="茗荷谷"; shortest_distance = 0.; pre_list = ["茗荷谷"]}
let station4 = {name="後楽園"; shortest_distance = infinity; pre_list = []}

(* 目的：未確定の駅 q を必要に応じて更新した駅を返す *)
(* update : station_t -> station_t -> station_t *)

let update p q = match (p, q) with
  ({name=pn; shortest_distance=ps; pre_list=pp},
   {name=qn; shortest_distance=qs; pre_list=qp}) ->
     let distance = get_distance pn qn global_between_list in
     if distance = infinity
     then q
     else if ps +. distance < qs
     then {name=qn; shortest_distance=ps +. distance; pre_list=qn::pp}
     else q

(* test *)
let test1 = update station3 station1 = station1
let test2 = update station3 station2 = station2
let test3 = update station3 station3 = station3
let test4 = update station3 station4 = {name="後楽園"; shortest_distance = 1.8; pre_list = ["後楽園"; "茗荷谷"]}
let test5 = update station2 station1 = {name="池袋"; shortest_distance = 3.0; pre_list = ["池袋"; "新大塚"; "茗荷谷"]}
let test6 = update station2 station2 = station2
let test7 = update station2 station3 = station3
let test8 = update station2 station4 = station4
