(* 問題14-6 from 浅井健一 著「プログラミングの基礎」 *)

type student_t = {
  name : string;
  score : int;
  grade : string;
}

let lst1 = []
let lst2 = [{name = "asai"; score = 70; grade = "B"}]
let lst3 = [{name = "asai"; score = 70; grade = "B"};
            {name = "kaneko"; score = 85; grade = "A"}]
let lst4 = [{name = "yoshida"; score = 80; grade = "A"};
            {name = "asai"; score = 70; grade = "B"};
            {name = "kaneko"; score = 85; grade = "A"}]

(* 目的：学生リスト lst のうち成績が grade0 の人の数を返す *)
(* count : student_t list -> string -> int *)

let count lst grade0 =
  let is_grade student = match student with
    {name = n; score = s; grade = g} -> grade0 = g
  in List.length(List.filter is_grade lst)

(* 目的：学生リスト lst のうち成績が A の人の数を返す *)
(* count_A : student_t list -> int *)

let count_A lst = count lst "A"

(* test *)
let test1 = count_A lst1 = 0
let test2 = count_A lst2 = 0
let test3 = count_A lst3 = 1
let test4 = count_A lst4 = 2
let test5 = count lst4 "B" = 1
let test6 = count lst4 "C" = 0
