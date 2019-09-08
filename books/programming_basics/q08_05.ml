(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 駅の情報を格納する型 *)
type information_t = {
  name: string; (* 名前 *)
  kana: string; (* 名前かな *)
  roman: string; (* 名前ローマ字 *)
  route: string; (* 路線 *)
}

(* 目的 : 駅間の接続情報を格納する型 *)
type between_t = {
  start_with: string; (* 出発駅 *)
  end_with: string; (* 到着駅 *)
  via: string; (* 経由駅 *)
  distance: float; (* 距離(km) *)
  min: int; (* 所要時間(分) *)
}

(* 目的 : 駅名を受け取って路線名・駅名(かな)を返す *)
(* display : station_information_t -> string *)
(*
let display station_information_t = match station_information_t with
  { name=n;kana=k;roman=rm;route=rt } ->
    rt ^ " / " ^ n ^ "(" ^ k ^")"
*)

(* test *)
(*
let test1 = display { name="茗荷谷";kana="みょうがだに";roman="myogadani";route="丸ノ内線" } = "丸ノ内線 / 茗荷谷(みょうがだに)"
*)
