let input = Advent.read_lines "day15.txt"
(* let _ = Advent.print_listof_strs input *)

module IntSet = Set.Make (Int)

module Position = struct
  type t = {
    x: int;
    y: int;
  }

  let init x y = { x; y }
  let distance a b = abs (a.x - b.x) + abs (a.y - b.y)
  let to_string p = Format.sprintf "(%d, %d)" p.x p.y
end

module Pairing = struct
  type t = {
    sensor: Position.t;
    beacon: Position.t;
    radius: int;
  }

  let init sensor beacon = { sensor; beacon; radius = Position.distance sensor beacon }
  let contains pair x y = pair.radius >= abs (pair.sensor.x - x) + abs (pair.sensor.y - y)

  let skip_to pair x y =
    let raw_x = pair.sensor.x - x in
    let x_dist = abs raw_x in
    let y_dist = abs (pair.sensor.y - y) in
    if pair.radius < x_dist + y_dist then
      None
    else
      Some (pair.sensor.x + pair.radius - y_dist + 1)
  ;;

  let to_string pair =
    Format.sprintf
      "s:%s b:%s"
      (Position.to_string pair.sensor)
      (Position.to_string pair.beacon)
  ;;
end

let parse_line line =
  let between s cs cf =
    let start = String.index s cs in
    let finish = String.index s cf in
    ( String.sub s (start + 1) (finish - start - 1),
      String.sub s (finish + 1) (String.length s - finish - 1) )
  in

  let after s cs =
    let start = String.index s cs in
    String.sub s (start + 1) (String.length s - start - 1)
  in

  let s_x, line = between line '=' ',' in
  let s_y, line = between line '=' ':' in
  let b_x, line = between line '=' ',' in
  let b_y = after line '=' in
  let sensor = Position.init (int_of_string s_x) (int_of_string s_y) in
  let beacon = Position.init (int_of_string b_x) (int_of_string b_y) in
  Pairing.init sensor beacon
;;

let intersect target pair set =
  let radius = Pairing.(pair.radius) in
  let y_dist = abs (target - pair.sensor.y) in
  if radius < y_dist then
    set
  else (
    let ns = Seq.init (radius - y_dist + 1) (fun a -> a) in
    Seq.fold_left
      (fun acc i ->
        let acc = IntSet.add (pair.sensor.x + i) acc in
        let acc = IntSet.add (pair.sensor.x - i) acc in
        acc)
      set
      ns
  )
;;

let part_1 input =
  let pairs = List.fold_left (fun acc row -> parse_line row :: acc) [] input in
  Pairing.to_string (List.hd pairs) |> print_endline;

  let n = 2000000 in
  let inter = List.fold_left (fun acc pair -> intersect n pair acc) IntSet.empty pairs in
  let beacons =
    List.fold_left
      (fun acc pair ->
        if Pairing.(pair.beacon.y) = n then
          IntSet.add pair.beacon.x acc
        else
          acc)
      IntSet.empty
      pairs
  in
  Format.sprintf "Intersection Cardinality: %d" (IntSet.cardinal inter) |> print_endline;
  Format.sprintf "Beacons Cardinality: %d" (IntSet.cardinal beacons) |> print_endline;
  Format.sprintf "Result: %d" (IntSet.cardinal inter - IntSet.cardinal beacons)
  |> print_endline
;;

let _ = if false then part_1 input

let part_2_bad input finish =
  let pairs = List.fold_left (fun acc row -> parse_line row :: acc) [] input in
  try
    for x = 0 to finish do
      Format.sprintf "Starting row: %d" x |> print_endline;
      for y = 0 to finish do
        let available =
          List.for_all (fun pair -> not (Pairing.contains pair x y)) pairs
        in
        if available then (
          Format.sprintf "done at %d, %d -> %d" x y ((x * 4000000) + y) |> print_endline;
          failwith "all done"
        )
      done
    done
  with
  | _ -> ()
;;

let _ = if false then part_2_bad input 20

let part_2 input finish =
  let pairs = List.fold_left (fun acc row -> parse_line row :: acc) [] input in
  let count = ref 0 in
  let rec inner x y =
    incr count;

    let skip_tos = List.filter_map (fun pair -> Pairing.skip_to pair x y) pairs in
    if List.length skip_tos = 0 then
      x, y
    else (
      let x = List.fold_left max 0 skip_tos in
      if x >= finish then
        inner 0 (y + 1)
      else
        inner x y
    )
  in
  let x, y = inner 0 0 in
  Format.sprintf "(comparison: %d) done at %d, %d -> %d" !count x y ((x * 4000000) + y)
  |> print_endline
;;

let _ = part_2 input 4000000
