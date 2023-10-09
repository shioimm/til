(* 問題8-2 from 浅井健一 著「プログラミングの基礎」 *)

type pocket_book_t = {
  name: string;
  price: int;
  store: string;
  date: string;
}

{
  name="プログラミングの基礎";
  price=2000;
  store="Books Kubrick"
  date="20XX-12-31"
}
(* - : pocket_book_t =
{name = "プログラミングの基礎"; price = 2000;
 store = "Books Kubrick"; date = "20XX-12-31"} *)
