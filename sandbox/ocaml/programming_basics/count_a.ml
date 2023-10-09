(* from 浅井健一 著「プログラミングの基礎」 *)

type student_t = {
  name : string; (* 名前 *)
  score : int; (* 点数 *)
  grade : string; (* 成績 *)
}

(* 目的 : 生徒のリストを受け取り、成績がAの生徒の人数を返す *)
(* count_a : student_t -> int *)

let rec count_a lst = match lst with
  [] -> 0
  | ({ name = n; score = s; grade = g } as first) :: rest ->
    if g = "A"
    then 1 + count_a rest
    else count_a rest

let student1 = {
  name = "Alice";
  score = 90;
  grade = "A"
}

let student2 = {
  name = "Bob";
  score = 50;
  grade = "C"
}

let list1 = []
let list2 = [student1; student2]
let list3 = [student2]

(* test *)
let test1 = count_a list1 = 0
let test2 = count_a list2 = 1
let test3 = count_a list3 = 0
