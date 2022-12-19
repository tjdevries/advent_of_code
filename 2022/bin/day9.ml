let input = Advent.read_lines "day9.txt"
(* let _ = Advent.print_listof_strs input *)

type pos = {
  x: int;
  y: int;
}

module CoordSet = Set.Make (struct
  type t = pos

  let compare = Stdlib.compare
end)

type direction =
  | Up
  | Down
  | Left
  | Right

module Move = struct
  type t = {
    dir: direction;
    amount: int;
  }

  let process move h t set =
    let rec inner move h t set =
      let h =
        match move.dir with
        | Right -> { h with x = h.x + 1 }
        | Left -> { h with x = h.x - 1 }
        | Up -> { h with y = h.y + 1 }
        | Down -> { h with y = h.y - 1 }
      in
      let t =
        match h.x - t.x, h.y - t.y with
        | 0, 0 -> t
        | x, y when abs x <= 1 && abs y <= 1 -> t
        | x, _ when x = 2 -> { h with x = t.x + 1 }
        | x, _ when x = -2 -> { h with x = t.x - 1 }
        | _, y when y = 2 -> { h with y = t.y + 1 }
        | _, y when y = -2 -> { h with y = t.y - 1 }
        | _ -> assert false
      in
      match move.amount with
      | 1 -> h, t, CoordSet.add t set
      | n -> inner { move with amount = n - 1 } h t (CoordSet.add t set)
    in
    inner move h t set
  ;;

  let process_2 move knots set =
    let n = Array.length knots in

    let move_head move hd =
      match move.dir with
      | Right -> { hd with x = hd.x + 1 }
      | Left -> { hd with x = hd.x - 1 }
      | Up -> { hd with y = hd.y + 1 }
      | Down -> { hd with y = hd.y - 1 }
    in

    let update h t =
      match h.x - t.x, h.y - t.y with
      | 0, 0 -> t
      | x, y when abs x <= 1 && abs y <= 1 -> t
      | x, y when abs x = 2 && abs y = 2 -> { x = (h.x + t.x) / 2; y = (h.y + t.y) / 2 }
      | x, _ when x = 2 -> { h with x = t.x + 1 }
      | x, _ when x = -2 -> { h with x = t.x - 1 }
      | _, y when y = 2 -> { h with y = t.y + 1 }
      | _, y when y = -2 -> { h with y = t.y - 1 }
      | x, y ->
        Format.printf "distance: %d %d\n" x y;
        assert false
    in

    let rec inner move set =
      knots.(0) <- move_head move knots.(0);

      for i = 1 to n - 1 do
        knots.(i) <- update knots.(i - 1) knots.(i)
      done;

      match move.amount with
      | 1 -> CoordSet.add knots.(n - 1) set
      | _ -> inner { move with amount = move.amount - 1 } (CoordSet.add knots.(n - 1) set)
    in

    inner move set
  ;;
end

let part_1 input =
  let h = { x = 0; y = 0 } in
  let t = { x = 0; y = 0 } in
  let set = CoordSet.empty in
  let folder (h, t, set) row =
    let d, amount = Advent.split_once ' ' row in
    let move =
      {
        Move.dir =
          (match d with
           | "R" -> Right
           | "U" -> Up
           | "L" -> Left
           | "D" -> Down
           | _ -> assert false);
        Move.amount = int_of_string amount;
      }
    in
    let h, t, set = Move.process move h t set in
    h, t, set
  in

  List.fold_left folder (h, t, set) input
;;

let _, _, m = part_1 input
let _ = Format.printf "Part 1: %d\n" (CoordSet.cardinal m)

let solve_n input n =
  let knots = Array.init n (fun _ -> { x = 0; y = 0 }) in
  let set = CoordSet.empty in
  let folder set row =
    let d, amount = Advent.split_once ' ' row in
    let move =
      {
        Move.dir =
          (match d with
           | "R" -> Right
           | "U" -> Up
           | "L" -> Left
           | "D" -> Down
           | _ -> assert false);
        Move.amount = int_of_string amount;
      }
    in
    Move.process_2 move knots set
  in

  List.fold_left folder set input
;;

let input = Advent.read_lines "day9.txt"
let set = solve_n input 2
let _ = Format.printf "Part 1: %d\n" (CoordSet.cardinal set)
let set = solve_n input 10
let _ = Format.printf "Part 2: %d\n" (CoordSet.cardinal set)
