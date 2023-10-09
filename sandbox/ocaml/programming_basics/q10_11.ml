(* 問題10-11 from 浅井健一 著「プログラミングの基礎」 *)

#use "q09_10.ml"

(* 目的：ふたつの駅の間の距離を求める *)
(* get_distance : string -> string -> between_t list -> float *)
let rec get_distance st1 st2 lst = match lst with
    [] -> infinity
  | { start_with=sw; end_with=ew; via=v; distance=d; min=m } :: rest ->
      if (sw = st1 && ew = st2) || (sw = st2 && ew = st1)
      then d
      else get_distance st1 st2 rest

(* test *)
let test1 = get_distance "茗荷谷" "新大塚" global_between_list = 1.2
let test2 = get_distance "茗荷谷" "池袋" global_between_list = infinity
let test3 = get_distance "東京" "大手町" global_between_list = 0.6
