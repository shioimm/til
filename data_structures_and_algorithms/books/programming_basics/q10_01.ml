(* 問題10-1 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 昇順の整数のリストlstと整数nを受け取り、正しい位置にnを挿入する *)
(* insert : list int -> int -> list int *)

let rec insert lst n = match lst with
    [] -> [n]
  | first :: rest ->
      if first < n
      then first :: insert rest n
      else n :: lst

(* test *)
let test1 = insert [] 1 = [1]
let test2 = insert [1; 3; 4; 7; 8] 5 = [1; 3; 4; 5; 7; 8]
