(* from 浅井健一 著「プログラミングの基礎」 *)

#use "notice.ml"

(* 目的 : 受け取ったlstの中から各gradeの人数を返す *)
(* student_max : student_t list -> int * int * int *)

let student1 = { name="nakamura"; score=90; grade="A" }
let student2 = { name="miyahara"; score=80; grade="A" }
let student3 = { name="sato"; score=75; grade="B" }
let student4 = { name="idehara"; score=70; grade="B" }
let student5 = { name="tsubata"; score=65; grade="C" }
let student6 = { name="asai"; score=60; grade="C" }

let lst1 = [student2]
let lst2 = [student3; student4]
let lst3 = [student4; student1; student6; student5; student2; student3]

let rec count_student lst = match lst with
    [] -> (0, 0, 0)
  | { name = n; score = s; grade = g } :: rest ->
      let (a, b, c) = count_student rest in
        if g = "A"
        then (a + 1, b, c)
        else if g = "B"
        then (a, b + 1, c)
        else if g = "C"
        then (a, b, c + 1)
        else (a, b, c)

(* test *)
let test1 = count_student lst1 = (1, 0, 0)
let test2 = count_student lst2 = (0, 2, 0)
let test3 = count_student lst3 = (2, 2, 2)
