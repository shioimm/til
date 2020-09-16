(* from 浅井健一 著「プログラミングの基礎」 *)

#use "q09_09.ml"
#use "q12_01.ml"

let informations = [
{name="池袋"; kana="いけぶくろ"; roman="ikebukuro"; route="丸ノ内線"};
{name="新大塚"; kana="しんおおつか"; roman="shinotsuka"; route="丸ノ内線"};
{name="茗荷谷"; kana="みょうがだに"; roman="myogadani"; route="丸ノ内線"};
{name="後楽園"; kana="こうらくえん"; roman="korakuen"; route="丸ノ内線"};
{name="本郷三丁目"; kana="ほんごうさんちょうめ"; roman="hongosanchome"; route="丸ノ内線"};
{name="御茶ノ水"; kana="おちゃのみず"; roman="ochanomizu"; route="丸ノ内線"}
]

(* 目的：information list から station list を作る *)
(* create_station_list : information_t list -> station_t list *)
let rec create_station_list informations = match informations with
    [] -> []
  | { name=n; kana=k; roman=rm; route=rt } :: rest ->
      { name=n; shortest_distance=infinity; pre_list=[]} ::create_station_list rest

(* test *)
let test1 = create_station_list [] = []
let test2 = create_station_list informations = [
{name="池袋"; shortest_distance = infinity; pre_list = []};
{name="新大塚"; shortest_distance = infinity; pre_list = []};
{name="茗荷谷"; shortest_distance = infinity; pre_list = []};
{name="後楽園"; shortest_distance = infinity; pre_list = []};
{name="本郷三丁目"; shortest_distance = infinity; pre_list = []};
{name="御茶ノ水"; shortest_distance = infinity; pre_list = []}
]
