(* 問題10-5 from 浅井健一 著「プログラミングの基礎」 *)

#use "notice.ml"

(* 目的 : 受け取ったlstの中からscoreが最も高いレコードを返す *)
(* student_max : student_t list -> student_t *)

let student1 = { name="nakamura"; score=90; grade="A" }
let student2 = { name="miyahara"; score=80; grade="A" }
let student3 = { name="sato"; score=75; grade="B" }
let student4 = { name="idehara"; score=70; grade="B" }
let student5 = { name="tsubata"; score=65; grade="C" }
let student6 = { name="asai"; score=60; grade="C" }

let lst1 = [student2]
let lst2 = [student3; student4]
let lst3 = [student4; student3]
let lst4 = [student4; student1; student6; student5; student2; student3]

let rec student_max lst = match lst with
    [] -> { name=""; score=min_int; grade="" }
  | ({ name = n; score = s; grade = g } as student) :: rest ->
      match student_max rest with
        { name = n_max; score = s_max; grade = g_max } ->
          if s_max < s
          then student
          else student_max rest

(* test *)
let test1 = student_max lst1 = student2
let test2 = student_max lst2 = student3
let test3 = student_max lst3 = student3
let test4 = student_max lst4 = student1
