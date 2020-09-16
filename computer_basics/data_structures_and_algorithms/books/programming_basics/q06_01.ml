(* 問題6-1 from 浅井健一 著「プログラミングの基礎」 *)

let square x = x * x ;;
square 3. ;;
(* Error: This expression has type float but an expression was expected of type
         int *)

let circle = 2. *. pi *. r ;;
(* Error: Unbound value pi *)

let TV bangumi youbi =
  bangumi ^ "は" ^ youbi ^ "に放映です" ;;
TV "ポケモン" "木曜日" ;;
(* Error: Syntax error *)
