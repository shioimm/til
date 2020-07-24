(* 問題22_2 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：受け取った配列にフィボナッチ数を順に入れて返す *)
(* fib_array : int array -> int array *)

let fib_array arr =
  let n = Array.length arr in
  let rec loop i =
    if i < n
    then (if i = 0
          then arr.(i) <- 0
          else if i = 1
          then arr(i) <- 0
          else arr.(i) <- arr.(i - 1) + arr.(i - 2);
          loop (i + 1))
    else () in
  (loop 0; arr)

(* test *)
let test = fib_array [|0; 0; 0; 0; 0; 0; 0; 0; 0; 0|]
	   = [|0; 1; 1; 2; 3; 5; 8; 13; 21; 34|]
