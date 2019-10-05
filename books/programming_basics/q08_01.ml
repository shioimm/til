(* 問題8-1 from 浅井健一 著「プログラミングの基礎」 *)

type book_t = {
  title: string;
  author: string;
  publisher: string;
  price: int;
  isbn: string;
}

{
  title = "プログラミングの基礎";
  author="浅井健一";
  publisher="サイエンス社";
  price=2000;
  isbn="978-X-XXXX-XXXX-1"
}
(* - : book_t =
{title = "プログラミングの基礎"; author = "浅井健一";
 publisher = "サイエンス社"; price = 2000; isbn = "978-X-XXXX-XXXX-1"} *)
