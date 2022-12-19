let input = Advent.read_lines "day12.txt"
(* let _ = Advent.print_listof_strs input *)

type pos = {
  x: int;
  y: int;
}

let print_pos pos = Format.sprintf "pos(%d,%d)" pos.x pos.y

module PosSet = Set.Make (struct
  type t = pos

  (* let compare a b = Stdlib.compare (a.x + a.y) (b.x + b.y) *)
  let compare = Stdlib.compare
end)

module PosMap = Map.Make (struct
  type t = pos

  (* let compare a b = Stdlib.compare (a.x + a.y) (b.x + b.y) *)
  let compare = Stdlib.compare
end)

let heuristic pnt dst = abs (pnt.x - dst.x) + abs (pnt.y - dst.y)

let can_move puzzle loc dst =
  let height = List.length input in
  let width = List.hd input |> String.length in
  if dst.x < 0 || dst.y < 0 || dst.x >= width || dst.y >= height then
    false
  else (
    let result = puzzle.(loc.y).(loc.x) + 1 >= puzzle.(dst.y).(dst.x) in

    (* Format.printf *)
    (*   "  can_move checking: %s %s %b\n" *)
    (*   (* puzzle.(loc.y).(loc.x) *) *)
    (*   (* puzzle.(dst.y).(dst.x) *) *)
    (*   (print_pos loc) *)
    (*   (print_pos dst) *)
    (*   result; *)

    (* 'd' 'b' , d + 1 >= b *)
    result
  )
;;

let test puzzle start finish =
  let mk pos direction = { x = pos.x + fst direction; y = pos.y + snd direction } in

  let check remaining checked costs current neighbor =
    if (not (can_move puzzle current neighbor)) || PosSet.mem neighbor checked then
      remaining, costs
    else (
      let current_cost = PosMap.find current costs in
      let neighbor_cost = current_cost + 1 in
      if
        (not (PosSet.mem neighbor remaining))
        || neighbor_cost < PosMap.find neighbor costs
      then (
        let costs = PosMap.add neighbor neighbor_cost costs in
        let remaining = PosSet.add neighbor remaining in
        remaining, costs
      ) else
        remaining, costs
    )
  in

  let check_all rem checked costs current =
    (* Process all the directions *)
    let rem, costs = check rem checked costs current (mk current (1, 0)) in
    let rem, costs = check rem checked costs current (mk current (-1, 0)) in
    let rem, costs = check rem checked costs current (mk current (0, 1)) in
    let rem, costs = check rem checked costs current (mk current (0, -1)) in
    rem, costs
  in

  let rec inner remaining checked costs current =
    (* if true || (PosSet.cardinal remaining = 0 && current = finish) then *)
    if current = finish then
      Some (PosMap.find current costs)
    else (
      let remaining, costs = check_all remaining checked costs current in

      (* Remove the current item from remaining *)
      let remaining = PosSet.remove current remaining in
      let checked = PosSet.add current checked in
      match PosSet.choose_opt remaining with
      | None -> None
      | Some rem ->
        let current =
          PosSet.to_seq remaining
          |> Seq.fold_left
               (fun minpos pos ->
                 if
                   heuristic minpos finish + PosMap.find minpos costs
                   > heuristic pos finish + PosMap.find pos costs
                 then
                   pos
                 else
                   minpos)
               rem
        in
        inner remaining checked costs current
    )
  in

  let remaining = PosSet.add start PosSet.empty in
  let costs = PosMap.add start 0 PosMap.empty in
  inner remaining PosSet.empty costs start
;;

let parse input =
  let height = List.length input in
  let width = List.hd input |> String.length in
  let start = ref (0, 0) in
  let finish = ref (0, 0) in
  let puzzle = Array.init height (fun _ -> Array.make width 0) in
  let iter_row y row =
    let iter_char x col =
      match col with
      | 'S' ->
        (* x, y *)
        start := x, y;
        puzzle.(y).(x) <- Char.code 'a' - Char.code 'a'
      | 'E' ->
        finish := x, y;
        puzzle.(y).(x) <- Char.code 'z' - Char.code 'a'
      | col -> puzzle.(y).(x) <- Char.code col - Char.code 'a'
    in
    String.iteri iter_char row
  in

  List.iteri iter_row input;
  let start = !start in
  let start = { x = fst start; y = snd start } in
  let finish = !finish in
  let finish = { x = fst finish; y = snd finish } in

  test puzzle start finish |> Option.get
;;

let parse_2 input =
  let height = List.length input in
  let width = List.hd input |> String.length in
  let starts = ref [] in
  let goal = ref (0, 0) in
  let puzzle = Array.init height (fun _ -> Array.make width 0) in
  let iter_row y row =
    let iter_char x col =
      match col with
      | 'E' ->
        goal := x, y;
        puzzle.(y).(x) <- Char.code 'z' - Char.code 'a'
      | 'a'
       |'S' ->
        starts := { x; y } :: !starts;
        puzzle.(y).(x) <- Char.code 'a' - Char.code 'a'
      | col -> puzzle.(y).(x) <- Char.code col - Char.code 'a'
    in
    String.iteri iter_char row
  in

  List.iteri iter_row input;
  let finish = !goal in
  let finish = { x = fst finish; y = snd finish } in

  (* TODO: Could save the work from previous iteration and re-use that in next round *)
  List.fold_left
    (fun minimum start ->
      print_pos start |> Format.sprintf "Checking start: %s" |> print_endline;

      match test puzzle start finish with
      | None -> minimum
      | Some dist -> min minimum dist)
    100000
    !starts
;;

(* test puzzle start finish *)

let runit _ =
  let result = parse input in
  let _ = print_endline "\n========\n" in
  let _ = Format.sprintf "Part 1: %d\n" result |> print_endline in
  let _ = print_endline "\n========\n" in
  let result = parse_2 input in
  let _ = Format.printf "Part 2: %d\n" result in
  print_endline "All done"
;;

let _ = runit ()
(* let _ = Advent.print_listof_ints (Array.to_list result.(0)) *)
(* let _ = Advent.print_listof_ints (Array.to_list result.(1)) *)
