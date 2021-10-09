(* from 浅井健一 著「プログラミングの基礎」 *)

#use "q12_01.ml"
let informations = [
{name="池袋"; shortest_distance = infinity; pre_list = []};
{name="新大塚"; shortest_distance = infinity; pre_list = []};
{name="茗荷谷"; shortest_distance = infinity; pre_list = []};
{name="後楽園"; shortest_distance = infinity; pre_list = []};
{name="本郷三丁目"; shortest_distance = infinity; pre_list = []};
{name="御茶ノ水"; shortest_distance = infinity; pre_list = []}
]

(* 目的：information list から station list を作る *)
(* init : station_t list -> string -> station_t list *)

let rec init informations start_with = match informations with
    [] -> []
  | ({name=n; shortest_distance = sd; pre_list = p} as first) :: rest ->
      if n = start_with
      then {name=n; shortest_distance=0.0; pre_list=[n]} :: init rest start_with
      else first :: init rest start_with

(* test *)
let test1 = init [] "茗荷谷" = []
let test2 = init informations "茗荷谷" = [
{name="池袋"; shortest_distance = infinity; pre_list = []};
{name="新大塚"; shortest_distance = infinity; pre_list = []};
{name="茗荷谷"; shortest_distance = 0.; pre_list = ["茗荷谷"]};
{name="後楽園"; shortest_distance = infinity; pre_list = []};
{name="本郷三丁目"; shortest_distance = infinity; pre_list = []};
{name="御茶ノ水"; shortest_distance = infinity; pre_list = []}
]
