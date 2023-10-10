(* 目的：級数の第 n 項の値を求める *)
(* series : int -> float *)

let rec series n =
  if n = o
  then 1.0
  else series (n - 1) /. float_to_int n

(* 目的：e の近似値を求める *)
(* approximation : int -> float *)

let approximation n =
  let s = series n
  in if s < 0.0001
     then s
     else s +. approximation (n + 1)
