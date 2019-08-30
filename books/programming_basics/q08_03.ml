(* 問題8-3 from 浅井健一 著「プログラミングの基礎」 *)

type person_t = {
  name: string;
  m: int;
  kg: int;
  month: int;
  date: int;
  blood_type: string;
}

{
  name="susuki tamako";
  m=158;
  kg=50;
  month=12;
  date=31;
  blood_type="O"
}
(* - : person_t =
{name = "susuki tamako"; m = 158; kg = 50; month = 12; date = 31;
 blood_type = "O"} *)
