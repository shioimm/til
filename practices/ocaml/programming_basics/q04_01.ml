(* 問題4-1 from 浅井健一 著「プログラミングの基礎」 *)

let uprate = 100 ;;
let base_pay = 850 ;;

let salary years hours = (base_pay + uprate * years) * hours ;;
(* val salary : int -> int -> int = <fun> *)

(* # salary 1 160 ;; => - : int = 152000 *)
(* # salary 3 140 ;; => - : int = 161000 *)
