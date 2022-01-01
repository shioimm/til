(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 学生一人分のデータを表す型 *)
type student_t = {
  name : string; (* 名前 *)
  score : int; (* 点数 *)
  grade : string; (* 成績 *)
}
(* type student_t = { name : string; score : int; grade : string; } *)

let notice student = match student with
  { name = n; score = s; grade = g; } ->
    n ^ "さんは" ^ string_of_int s ^ "点で、成績は" ^ g ^ "です"
(* val notice : student_t -> string = <fun> *)

(* 目的 : 点数を元に成績を返す *)
let evaluation student = match student with
  { name = n; score = s; grade = g } ->
    { name = n;
      score = s;
      grade = if s >= 80 then "A"
               else if s >= 70 then "B"
               else if s >= 60 then "C" else "D"} ;;
(* val notice : student_t -> student_t = <fun> *)

(* 目的 : 学生のデータstudent_tを受け取り、成績のついたデータとして返す *)
(* evaluation: student_t -> student_t *)
evaluation { name = "suzuki"; score = 80; grade = "" } ;;
(* - : student_t = {name = "suzuki"; score = 80; grade = "A"} *)

notice (evaluation { name = "suzuki"; score = 80; grade = "" })
(* type student_t = { name : string; score : int; grade : string; }
val notice : student_t -> string = <fun>
val evaluation : student_t -> student_t = <fun>
- : student_t = {name = "suzuki"; score = 80; grade = "A"}
- : string = "suzukiさんは80点で、成績はAです" *)
