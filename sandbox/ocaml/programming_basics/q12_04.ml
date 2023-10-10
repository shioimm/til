#use "q08_05.ml"

let informations = [
{name="池袋"; kana="いけぶくろ"; roman="ikebukuro"; route="丸ノ内線"};
{name="新大塚"; kana="しんおおつか"; roman="shinotsuka"; route="丸ノ内線"};
{name="茗荷谷"; kana="みょうがだに"; roman="myogadani"; route="丸ノ内線"};
{name="後楽園"; kana="こうらくえん"; roman="korakuen"; route="丸ノ内線"};
{name="本郷三丁目"; kana="ほんごうさんちょうめ"; roman="hongosanchome"; route="丸ノ内線"};
{name="御茶ノ水"; kana="おちゃのみず"; roman="ochanomizu"; route="丸ノ内線"}
]

(* 目的：昇順に並んでいる lst の正しい位置に information を挿入する *)
(* information_insert : information_t list -> information_t -> information_t list *)

let rec information_insert lst information0 = match lst with
    [] -> [information0]
  | ({name=n; kana=k; roman=rm; route=rt} as information) :: rest ->
      match information0 with
        {name=n0; kana=k0; roman=rm0; route=rt0} ->
          if k = k0
          then information_insert rest information0
          else if k < k0
          then information :: information_insert rest information0
          else information0 :: lst

(* test *)
let test1 = information_insert [] {name="茗荷谷"; kana="みょうがだに"; roman="myogadani"; route="丸ノ内線"}
	    = [{name="茗荷谷"; kana="みょうがだに"; roman="myogadani"; route="丸ノ内線"}]
let test2 = information_insert [
	{name="池袋"; kana="いけぶくろ"; roman="ikebukuro"; route="丸ノ内線"};
	{name="御茶ノ水"; kana="おちゃのみず"; roman="ochanomizu"; route="丸ノ内線"};
	{name="新大塚"; kana="しんおおつか"; roman="shinotsuka"; route="丸ノ内線"};
	{name="本郷三丁目"; kana="ほんごうさんちょうめ"; roman="hongosanchome"; route="丸ノ内線"};
	{name="茗荷谷"; kana="みょうがだに"; roman="myogadani"; route="丸ノ内線"}
	]
	{name="後楽園"; kana="こうらくえん"; roman="korakuen"; route="丸ノ内線"}
= [
{name="池袋"; kana="いけぶくろ"; roman="ikebukuro"; route="丸ノ内線"};
{name="御茶ノ水"; kana="おちゃのみず"; roman="ochanomizu"; route="丸ノ内線"};
{name="後楽園"; kana="こうらくえん"; roman="korakuen"; route="丸ノ内線"};
{name="新大塚"; kana="しんおおつか"; roman="shinotsuka"; route="丸ノ内線"};
{name="本郷三丁目"; kana="ほんごうさんちょうめ"; roman="hongosanchome"; route="丸ノ内線"};
{name="茗荷谷"; kana="みょうがだに"; roman="myogadani"; route="丸ノ内線"}
]

(* 目的：information list をひらがなの順に整列しながら駅の重複を取り除く *)
(* sort : information_t list -> information_t list *)

let rec sort lst = match lst with
    [] -> []
  | first :: rest ->
      information_insert (sort rest) first

(* test *)
let test3 = sort [] = []
let test4 = sort informations = [
{name="池袋"; kana="いけぶくろ"; roman="ikebukuro"; route="丸ノ内線"};
{name="御茶ノ水"; kana="おちゃのみず"; roman="ochanomizu"; route="丸ノ内線"};
{name="後楽園"; kana="こうらくえん"; roman="korakuen"; route="丸ノ内線"};
{name="新大塚"; kana="しんおおつか"; roman="shinotsuka"; route="丸ノ内線"};
{name="本郷三丁目"; kana="ほんごうさんちょうめ"; roman="hongosanchome"; route="丸ノ内線"};
{name="茗荷谷"; kana="みょうがだに"; roman="myogadani"; route="丸ノ内線"}
]
