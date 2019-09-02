(* 問題10-3 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 学生のリストstudent_tを受け取り、scoreの昇順にして返す *)
(* student_sort : student_t list -> student_t -> student_t list *)

#use "notice.ml"
#use "q10_02.ml"

let student1 = {name="nakamura"; score=90; grade="A"}
let student2 = {name="miyahara"; score=80; grade="A"}
let student3 = {name="sato"; score=75; grade="B"}
let student4 = {name="idehara"; score=70; grade="B"}
let student5 = {name="tsubata"; score=65; grade="C"}
let student6 = {name="asai"; score=60; grade="C"}

let lst1 = []
let lst2 = [student2]
let lst3 = [student3; student4]
let lst4 = [student4; student3]
let lst5 = [student4; student1; student6; student5; student2; student3]

let rec student_insert lst student0 = match lst with
    [] -> [student0]
  | ({ name = n1; score = s1; grade = g1 } as student1) :: rest ->
      match student0 with
        { name = n0; score = s0; grade = g0 } ->
          if s0 > s1
          then student1 :: student_insert rest student0
          else student0 :: lst

(* テスト *)
let test1 = student_insert [] student2
          = [student2]
let test2 = student_insert [student4] student3
          = [student4; student3]
let test3 = student_insert [student3] student4
          = [student4; student3]
let test4 = student_insert [student6; student5; student3; student2; student1] student4
          = [student6; student5; student4; student3; student2; student1]

let rec student_ins_sort lst = match lst with
    [] -> []
  | first :: rest ->
    student_insert (student_ins_sort rest) first

(* test *)
let test5 = student_ins_sort lst1 = []
let test6 = student_ins_sort lst2 = [student2]
let test7 = student_ins_sort lst3 = [student4; student3]
let test8 = student_ins_sort lst4 = [student4; student3]
let test9 = student_ins_sort lst5 = [student6; student5; student4; student3; student2; student1]
