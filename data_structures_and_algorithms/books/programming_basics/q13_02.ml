(* from 浅井健一 著「プログラミングの基礎」 *)

#use "q08_03.ml"

let lst = [suzuki;yamada; sato]

let name person = match person with
  { name=n; m=m; kg=kg; month=mon; date=date; blood_type=bt } -> n

let names lst = List.map name lst

(* test *)
let test1 = names [] = []
let test2 = names lst = ["susuki tamako"; "yamada otoko"; "sato nanzokore"]
