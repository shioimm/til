(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：n から 1 までのリストを作る *)
(* enumerate : int -> int list *)

let rec enumerate n =
  if n = 0
  then []
  else n :: enumerate (n - 1)

(* 目的：n の約数のリストを返す *)
(* divisor : int -> int list *)

let divisor n =
  List.filter (fun x -> n mod x = 0) (enumerate n)

(* 目的：m 以下の完全数のリストを返す *)
(* perfect : int -> int list *)

let perfect m =
  List.filter (fun n -> (List.fold_right (+) (divisor n) 0) - n = n) (enumerate m)

(* test *)
let test1 = divisor 24 = [24; 12; 8; 6; 4; 3; 2; 1]
let test2 = perfect 10000 = [8128; 496; 28; 6]
