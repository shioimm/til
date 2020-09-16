(* 問題17-4 from 浅井健一 著「プログラミングの基礎」 *)

#use "q17_02.ml"
#use "q17_03.ml"

(* 目的：日付を受け取ってきたら星座を返す *)
(* constellation : year_t -> constellation_t *)

let constellation year = match year with
    January (date) -> if date <= 19 then Capricorus else Aquarius
  | February (date) -> if date <= 18 then Aquarius else Pisces
  | March (date) -> if date <= 20 then Pisces else Aries
  | April (date) -> if date <= 19 then Aries else Taurus
  | May (date) -> if date <= 20 then Taurus else Gemini
  | June (date) -> if date <= 21 then Gemini else Cancer
  | July (date) -> if date <= 22 then Cancer else Leo
  | August (date) -> if date <= 22 then Leo else Virgo
  | September (date) -> if date <= 22 then Virgo else Libra
  | October (date) -> if date <= 23 then Libra else Scorpius
  | November (date) -> if date <= 21 then Scorpius else Sagittarius
  | December (date) -> if date <= 21 then Sagittarius else Capricorus

(* test *)
let test1 = seiza (June (11)) = Gemini
let test2 = seiza (June (30)) = Cancer
let test3 = seiza (September (17)) = Virgo
let test4 = seiza (October (7)) = Libra
