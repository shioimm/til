(* 問題14-4 from 浅井健一 著「プログラミングの基礎」 *)

type student_t = {
  name : string;
  score : int;
  grade : string;
}

(* student_t list 型のデータの例 *)
let lst1 = []
let lst2 = [{name = "asai"; score = 70; grade = "B"}]
let lst3 = [{name = "asai"; score = 70; grade = "B"};
            {name = "kaneko"; score = 85; grade = "A"}]
let lst4 = [{name = "yoshida"; score = 80; grade = "A"};
            {name = "asai"; score = 70; grade = "B"};
            {name = "kaneko"; score = 85; grade = "A"}]

(* 目的：受け取った学生リスト lst の得点の合計を返す *)
(* add_score : student_t -> int -> int *)

let add_score first rest_result = match first with
  {name = n; score = s; grade = g} -> s + rest_result

(* 目的：受け取った学生リスト lst の得点の合計を返す *)
(* student_sum : student_t list -> int *)
let student_sum lst = List.fold_right add_score lst 0

(* test *)
let test1 = student_sum lst1 = 0
let test2 = student_sum lst2 = 70
let test3 = student_sum lst3 = 155
let test4 = student_sum lst4 = 235
