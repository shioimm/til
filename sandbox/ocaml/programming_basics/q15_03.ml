(* 問題15-3 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：2 から n までの自然数を受け取り 2 から n までの素数を返す *)
(* sieve : int list -> int list *)

let rec sieve lst = match lst with
    [] -> []
  | first :: rest ->
      first :: sieve (List.filter (fun x -> x mod first <> 0) rest)

(* test *)
let test1 = sieve [2; 3; 4; 5; 6; 7; 8; 9; 10] = [2; 3; 5; 7]

(* 目的：2 から受け取った自然数 n までの自然数のリストを返す *)
(* two_to_n : int -> int list *)

let rec two_to_n n =
  let rec loop i =
    if i <= n
    then i :: loop (i + 1)
    else []
  in loop 2

(* test *)
let test2 = two_to_n 10 = [2; 3; 4; 5; 6; 7; 8; 9; 10]

(* 目的：2 から受け取った自然数 n までの素数を返す *)
(* prime : int -> int list *)

let rec prime n =
  sieve (two_to_n n)

(* test *)
let test3 = prime 10 = [2; 3; 5; 7]
