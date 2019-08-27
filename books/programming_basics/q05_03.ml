(* 問題5-3 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 誕生日を受け取り、星座を返す *)
(* astrology : float -> string *)

let astrology x =
  if 1.20 <= x && x <= 2.18 then "水瓶座"
  else if 2.19 <= x && x <= 3.20 then "魚座"
  else if 3.21 <= x && x <= 4.19 then "牡羊座"
  else if 4.20 <= x && x <= 5.20 then "牡牛座"
  else if 5.21 <= x && x <= 6.21 then "双子座"
  else if 6.22 <= x && x <= 7.22 then "蟹座"
  else if 7.23 <= x && x <= 8.22 then "獅子座"
  else if 8.23 <= x && x <= 9.22 then "乙女座"
  else if 9.23 <= x && x <= 10.23 then "天秤座"
  else if 10.24 <= x && x <= 11.22 then "蠍座"
  else if 11.23 <= x && x <= 12.21 then "射手座"
  else if 12.22 <= x || x <= 1.19 then "山羊座"
  else "Error"

(* test *)
let test1 = astrology 4.15 = "牡羊座"
let test2 = astrology 5.30 = "双子座"
let test3 = astrology 8.10 = "獅子座"
let test4 = astrology 11.05 = "蠍座"
let test5 = astrology 12.25 = "山羊座"
let test6 = astrology 1.15 = "山羊座"
