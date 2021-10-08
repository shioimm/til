(* from 浅井健一 著「プログラミングの基礎」 *)

(* 目的：受け取った点 (a, b) から点 (x, y) までの距離を求める *)
(* kyori : float * float -> float *)

module Coordinate = struct
  let x = 3.0
  let y = 4.0

  let distance (a, b) = sqrt ((x -. a) *. (x -. a) +. (y -. b) *. (y -. b))
end

Coordinate.x ;;
  Coordinate.distance 2.0 1.0 ;;
