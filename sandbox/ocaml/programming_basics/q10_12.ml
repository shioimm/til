(* 問題10-11 from 浅井健一 著「プログラミングの基礎」 *)

#use "q10_10.ml"
#use "q10_11.ml"

(* 目的：ふたつの駅の間の距離を文字列で表現する *)
(* display_distance : string string -> string *)
let display_distance st1 st2 =
  let name1 = roman_to_name st1 station_information_list in
  if name1 = ""
  then st1 ^ " という駅は存在しません"
  else let name2 = roman_to_name st2 global_information_list in
    if name2 = ""
    then st2 ^ " という駅は存在しません"
    else let distance = get_distance st1 st2 global_between_list in
      if distance = infinity
      then st1 ^ "と" ^ st2 "はつながっていません"
      else st1 ^ "から" ^ st2 "までは" ^ string_of_float distance ^ "です"

(* test *)
let test1 = display_distance "myougadani" "shinotsuka" = "myougadani という駅は存在しません"
let test1 = display_distance "myogadani" "shinotsuka" = "茗荷谷から新大塚までは 1.2 キロです"
let test1 = display_distance "myogadani" "ikebukuro" = "茗荷谷と池袋はつながっていません"
let test1 = display_distance "tokyo" "ootemachi" = "ootemachi という駅は存在しません"
let test1 = display_distance "tokyo" "otemachi"= "東京から大手町までは 0.6 キロです"
