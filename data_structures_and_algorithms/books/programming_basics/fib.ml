(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：フィボナッチ数を再帰回数とともに求める *)
(* fib : int -> (int * int) *)

let count = ref 0

let rec fib n =
  count := !count + 1;
  if n < 2
  then n
  else
    fib (n - 1) + fib (n - 2)

(* test *)
let test = fib 8 = 21;

print_int !count;
