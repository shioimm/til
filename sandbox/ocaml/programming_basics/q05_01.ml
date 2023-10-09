(* 問題5-1 from 浅井健一 著「プログラミングの基礎」 *)

if 2 > 1 then 3 else 4 ;;
(* - : int = 3 *)

if "true" then 3.14 else 2.72
(* Error: This expression has type string but an expression was expected of type
         bool
       because it is in the condition of an if-statement *)
(* 条件式の評価結果は明確にbool型である必要がある *)

if "a" = "b" then false else true ;;
(* - : bool = true *)

if true < false then 1 else "2" ;;
(* Error: This expression has type string but an expression was expected of type
         int *)
(* true < false は falseになる *)

if not (3 = 4) then 1 < 2 else 1 > 2 ;;
(* - : bool = true *)
