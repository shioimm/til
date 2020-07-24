(* 問題21-2 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：2 から n までの自然数を受け取り 2 から n までの素数を返す *)
(* sieve : int list -> int list *)

let rec sieve lst =
  (print_int (List.length lst);
   print_newline();

   match lst with
     [] -> []
   | first :: rest ->
       first :: sieve (List.filter (fun x -> x mod first <> 0) rest))

(* test *)
let test1 = sieve [2; 3; 4; 5; 6; 7; 8; 9; 10] = [2; 3; 5; 7]
