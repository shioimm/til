(* 問題8-4 from 浅井健一 著「プログラミングの基礎」 *)

(* 目的 : 人ひとりのデータを返す型 *)
type person_t = {
  name: string; (* 名前 *)
  blood_type: string; (* 血液型 *)
}

(* 目的 : person_tのデータを受け取り、名前と血液型を返す *)
(* display_blood_type: person_t -> string *)
let display_blood_type person_t = match person_t with
  { name = n; blood_type = b } ->
    n ^ "さんの血液型は" ^ b ^"型です"

(* test *)
let test1 = display_blood_type { name="suzuki";blood_type="A" } = "suzukiさんの血液型はA型です"
let test2 = display_blood_type { name="yamada";blood_type="B" } = "yamadaさんの血液型はB型です"
let test3 = display_blood_type { name="tanaka";blood_type="O" } = "tanakaさんの血液型はO型です"
let test4 = display_blood_type { name="sato";blood_type="AB" } = "satoさんの血液型はAB型です"
