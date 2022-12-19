let input = Advent.read_lines "day14.txt"
let _ = Advent.print_listof_strs input

module IntSet = Set.Make (Int)

module Position = struct
  type t = {
    x: int;
    y: int;
  }

  (* let to_string pos = Format.sprintf "(%d,%d)" pos.x pos.y *)

  let between a b =
    match a, b with
    | a, b when a.x = b.x ->
      let start = min a.y b.y in
      let dist = a.y - b.y in
      let dist = abs dist + 1 in
      List.init dist (fun idx -> { x = a.x; y = start + idx })
    | a, b when a.y = b.y ->
      let start = min a.x b.x in
      let dist = a.x - b.x in
      let dist = abs dist + 1 in
      List.init dist (fun idx -> { x = start + idx; y = a.y })
    | _ -> assert false
  ;;

  let below pos = { pos with y = pos.y + 1 }
  let diag_left pos = { x = pos.x - 1; y = pos.y + 1 }
  let diag_right pos = { x = pos.x + 1; y = pos.y + 1 }
  let compare = Stdlib.compare
end

module PosSet = Set.Make (Position)

let display rocks sand (topleft : Position.t) (botright : Position.t) =
  let pixels =
    Array.init
      (botright.y - topleft.y + 1)
      (fun _ -> Array.make (botright.x - topleft.x + 1) ".")
  in

  PosSet.iter (fun pos -> pixels.(pos.y).(pos.x - topleft.x) <- "#") rocks;
  PosSet.iter
    (fun pos ->
      try pixels.(pos.y).(pos.x - topleft.x) <- "o" with
      | _ -> ())
    sand;

  Array.iter (fun row -> Array.to_list row |> String.concat "" |> print_endline) pixels
;;

let simulate x_goals y_max (rocks : PosSet.t) (sand : PosSet.t) (pos : Position.t) =
  let is_available pos = (not (PosSet.mem pos rocks)) && not (PosSet.mem pos sand) in
  let rec inner pos =
    let botleft pos =
      let newpos = Position.diag_left pos in
      if is_available newpos then
        Some (inner newpos)
      else
        None
    in

    let botright pos =
      let newpos = Position.diag_right pos in
      if is_available newpos then
        Some (inner newpos)
      else
        None
    in

    let sides pos =
      match botleft pos with
      | None ->
        (match botright pos with
         | None -> pos, false
         | Some (pos, stop) -> pos, stop)
      | Some (pos, stop) -> pos, stop
    in

    if (not (IntSet.mem pos.x x_goals)) || pos.y > y_max then
      pos, true
    else (
      let below = Position.below pos in
      let rock_below = PosSet.mem below rocks in
      let sand_below = PosSet.mem below sand in
      match rock_below, sand_below with
      | false, false -> inner below
      | true, true -> assert false
      | _ -> sides pos
    )
  in

  let pos, stop = inner pos in
  PosSet.add pos sand, stop
;;

let parse input =
  let add_between acc left right =
    let between = Position.between left right in
    List.fold_left (fun acc pos -> PosSet.add pos acc) acc between
  in

  let add_all acc pos_list =
    let rec inner acc pos_list =
      match pos_list with
      | a :: (b :: _ as rest) -> inner (add_between acc a b) rest
      | _ -> acc
    in
    inner acc pos_list
  in

  let fold_line acc line =
    let items = Str.split (Str.regexp " -> ") line in
    let xys =
      List.map
        (fun item ->
          let x, y = Advent.split_once ',' item in
          let x = int_of_string x in
          let y = int_of_string y in
          Position.{ x; y })
        items
    in
    add_all acc xys
  in
  let rocks = List.fold_left fold_line PosSet.empty input in
  let sand = PosSet.empty in

  if false then display rocks sand { x = 494; y = 0 } { x = 503; y = 9 };

  let rocks = ref rocks in
  let y_max = PosSet.fold (fun y acc -> max y.y acc) !rocks 0 + 2 in
  let x_goals = PosSet.fold (fun x acc -> IntSet.add x.x acc) !rocks IntSet.empty in

  (* let _ = display !rocks sand { x = 470; y = 0 } { x = 530; y = 12 } in *)
  let sand_ref = ref sand in
  let stop_ref = ref false in
  while !stop_ref do
    let sand, stop = simulate x_goals y_max !rocks !sand_ref { x = 500; y = 0 } in
    sand_ref := sand;
    stop_ref := stop
  done;

  let count = ref 0 in
  let dostuff (sand, stop) _ =
    Format.sprintf "%d stop: %b" !count stop |> print_endline;

    if stop then
      failwith "time to be done"
    else (
      incr count;
      let sand, stop = simulate x_goals y_max !rocks sand { x = 500; y = 0 } in
      (* let _ = display rocks sand { x = 494; y = 0 } { x = 503; y = 9 } in *)
      sand, stop
    )
  in

  let _ =
    try Seq.fold_left dostuff (sand, false) (Seq.init 1000 (fun a -> a)) with
    | _ -> sand, false
  in
  Format.sprintf "count: %d" !count |> print_endline
;;

let _ = parse input

let simulate_2 (rocks : PosSet.t) (sand : PosSet.t) (pos : Position.t) =
  let is_available pos = (not (PosSet.mem pos rocks)) && not (PosSet.mem pos sand) in
  let rec inner pos =
    let botleft pos =
      let newpos = Position.diag_left pos in
      if is_available newpos then
        Some (inner newpos)
      else
        None
    in

    let botright pos =
      let newpos = Position.diag_right pos in
      if is_available newpos then
        Some (inner newpos)
      else
        None
    in

    let sides pos =
      match botleft pos with
      | None ->
        (match botright pos with
         | None -> pos, false
         | Some (pos, stop) -> pos, stop)
      | Some (pos, stop) -> pos, stop
    in

    let below = Position.below pos in
    let rock_below = PosSet.mem below rocks in
    let sand_below = PosSet.mem below sand in
    match rock_below, sand_below with
    | false, false -> inner below
    | true, true -> assert false
    | _ -> sides pos
  in

  let pos, _ = inner pos in
  let stop = pos.x = 500 && pos.y = 0 in
  PosSet.add pos sand, stop
;;

let parse_2 input =
  let add_between acc left right =
    let between = Position.between left right in
    List.fold_left (fun acc pos -> PosSet.add pos acc) acc between
  in

  let add_all acc pos_list =
    let rec inner acc pos_list =
      match pos_list with
      | a :: (b :: _ as rest) -> inner (add_between acc a b) rest
      | _ -> acc
    in
    inner acc pos_list
  in

  let fold_line acc line =
    let items = Str.split (Str.regexp " -> ") line in
    let xys =
      List.map
        (fun item ->
          let x, y = Advent.split_once ',' item in
          let x = int_of_string x in
          let y = int_of_string y in
          Position.{ x; y })
        items
    in
    add_all acc xys
  in
  let rocks = List.fold_left fold_line PosSet.empty input in
  let sand = PosSet.empty in
  let rocks = ref rocks in
  let y_max = PosSet.fold (fun y acc -> max y.y acc) !rocks 0 + 2 in
  for idx = 0 to y_max + 10 do
    rocks := PosSet.add { x = 500 - idx; y = y_max } !rocks;
    rocks := PosSet.add { x = 500 + idx; y = y_max } !rocks
  done;

  let sand_ref = ref sand in
  let stop_ref = ref false in
  while !stop_ref do
    let sand, stop = simulate_2 !rocks !sand_ref { x = 500; y = 0 } in
    sand_ref := sand;
    stop_ref := stop
  done;

  let count = ref 0 in
  let dostuff (sand, stop) _ =
    Format.sprintf "%d stop: %b" !count stop |> print_endline;

    if stop then
      failwith "time to be done"
    else (
      incr count;
      let sand, stop = simulate_2 !rocks sand { x = 500; y = 0 } in
      (* let _ = display rocks sand { x = 494; y = 0 } { x = 503; y = 9 } in *)
      sand, stop
    )
  in

  let _ =
    try Seq.fold_left dostuff (sand, false) (Seq.init 100000 (fun a -> a)) with
    | _ -> sand, false
  in
  Format.sprintf "count: %d" !count |> print_endline
;;

let _ = parse_2 input
