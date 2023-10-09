(* from 浅井健一 著「プログラミングの基礎」 *)

type distance_t = {
  distance : int;
  total : int;
}

(* 目的：先頭からリスト中の各点までの距離の合計を計算する *)
(* total_distance : distance_t list -> distance_t list *)

let total_distance lst =
  (* 目的：先頭からリスト中の各点までの距離の合計を計算する *)
  (* hojo : distance_t list -> float -> distance_t list *)
  let rec sub lst total0 = match lst with
      [] -> []
    | {distance = d; total = t} :: rest ->
        {distance = d; total= total0 + d} :: sub rest (total0 + d)
  in sub lst 0


(* test *)
let test = total_distance [
  {distance = 3; total = 0};
  {distance = 9; total = 0};
  {distance = 14; total = 0};
  {distance = 8; total = 0}
] = [
  {distance = 3; total = 3};
  {distance = 9; total = 12};
  {distance = 14; total = 26};
  {distance = 8; total = 34}
]
