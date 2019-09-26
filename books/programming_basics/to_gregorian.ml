(* 目的：年号を受け取ったら対応する西暦年を返す *)
(* to_gregorian : year_t -> int *)

type year_t = Meiji of int
              | Taisho of int
              | Showa of int
              | Heisei of int
              | Reiwa of int

let to_gregorian year = match year with
    Meiji (n) -> n + 1867
  | Taisho (n) -> n + 1911
  | Showa (n) -> n + 1925
  | Heisei (n) -> n + 1988
  | Reiwa (n) -> n + 2019

(* test *)
let test1 = to_gregorian (Showa (42)) = 1967
let test2 = to_gregorian (Heisei (11)) = 1999
let test3 = to_gregorian (Meiji (41)) = 1908
