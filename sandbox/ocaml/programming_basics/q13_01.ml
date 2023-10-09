(* 問題13-1 from 浅井健一 著「プログラミングの基礎」 *)

#use "q08_03.ml"

let lst = [suzuki; yamada; sato]

(* 目的：人のリスト lst のうち血液型が bt0 の人の数を返す *)
(* count_bt : person_t list -> string -> int *)
let rec count_bt lst bt0 = match lst with
    [] -> 0
  | {name=n; m=m; kg=kg; month=mon; date=dt; blood_type=bt} :: rest ->
      if bt = bt0
      then 1 + count_bt rest bt0
      else count_bt rest bt0

(* test *)
let test1 = count_bt [] "A" = 0
let test2 = count_bt lst "A" = 1
let test3 = count_bt lst "O" = 2
let test4 = count_bt lst "B" = 0
let test5 = count_bt lst "AB" = 0
