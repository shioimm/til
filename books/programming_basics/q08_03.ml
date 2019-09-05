(* 問題8-3 from 浅井健一 著「プログラミングの基礎」 *)

type person_t = {
  name: string;
  m: int;
  kg: int;
  month: int;
  date: int;
  blood_type: string;
}

let suzuki = {
  name="susuki tamako";
  m=158;
  kg=50;
  month=12;
  date=31;
  blood_type="O"
}

let yamada = {
  name="yamada otoko";
  m=176;
  kg=68;
  month=1;
  date=1;
  blood_type="A"
}

let sato = {
  name = "sato nanzokore";
  m = 168;
  kg = 60;
  month = 8;
  date = 5;
  blood_type = "O"
}

(*
val suzuki : person_t =
  {name = "susuki tamako"; m = 158; kg = 50; month = 12; date = 31;
   blood_type = "O"}
val yamada : person_t =
  {name = "yamada otoko"; m = 176; kg = 68; month = 1; date = 1;
   blood_type = "A"}
*)
