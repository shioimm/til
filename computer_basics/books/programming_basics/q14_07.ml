(* 問題14-7 from 浅井健一 著「プログラミングの基礎」 *)

#use "q10_11.ml"
#use "q12_01.ml"

let station1 = {name="池袋"; shortest_distance = infinity; pre_list = []}
let station2 = {name="新大塚"; shortest_distance = 1.2; pre_list = ["新大塚"; "茗荷谷"]}
let station3 = {name="茗荷谷"; shortest_distance = 0.; pre_list = ["茗荷谷"]}
let station4 = {name="後楽園"; shortest_distance = infinity; pre_list = []}


(* 目的：未確定の駅のリスト v を必要に応じて更新したリストを返す *)
(* update_list : station_t -> station_t list -> station_t list *)

let update_list p v =
  let update_list1 p q = match (p, q) with
    ({name = pn; shortest_distance = ps; pre_list = pt},
      {name = qn; shortest_distance = qs; pre_list = qt}) ->
        let distance = get_distance pn qn global_between_list
        in if distance = infinity
          then q
          else if ps +. distance < qs
          then {name = qn; shortest_distance = ps +. distance; pre_list = qn :: pt}
          else q
          in let f q = update_list1 p q
          in List.map f v

let lst = [station1; station2; station3; station4]
(* test *)
let test1 = update_list station2 [] = []
let test2 = update_list station2 lst =
 [{name="池袋"; shortest_distance = 3.0; pre_list = ["池袋"; "新大塚"; "茗荷谷"]};
  station2; station3; station4]
