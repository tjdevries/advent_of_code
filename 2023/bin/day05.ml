open Core
open Advent.A

let parse_seeds = string "seeds: " *> sep_by1 space digit

type range_map =
  { destination : int
  ; source : int
  ; length : int
  }
[@@deriving show]

let parse_range_map =
  let* destination = wmatch digit in
  let* source = wmatch digit in
  let* length = digit in
  return { destination; source; length }
;;

let parse_map =
  let* _ = take_till (fun ch -> Char.(ch = '\n')) in
  sep_by1 newline parse_range_map
;;

let puzzle =
  let* seeds = parse_seeds in
  let* _ = whitespace in
  let* ranges = sep_by1 (string "\n\n") parse_map in
  return (seeds, ranges)
;;

let parse_puzzle lines =
  let seeds = parse_string ~consume:Prefix puzzle lines in
  seeds
;;

let map_seed seed maps =
  List.fold maps ~init:seed ~f:(fun seed map ->
    let range =
      List.find map ~f:(fun range ->
        range.source <= seed && range.source + range.length >= seed)
    in
    match range with
    | Some range -> seed - range.source + range.destination
    | None -> seed)
;;

let () =
  let input = Advent.read_all "./inputs/05-prod.txt" in
  let input = parse_puzzle input in
  let seeds, maps =
    match input with
    | Ok (seeds, maps) ->
      (* List.iter seeds ~f:(Fmt.pr "seed: %d@."); *)
      (* List.iteri maps ~f:(fun idx m -> *)
      (*   Fmt.pr "==> %d@." idx; *)
      (*   List.iter m ~f:(Fmt.pr "matched: %a@." pp_range_map)); *)
      seeds, maps
    | Error err -> Fmt.failwith "Parsing failed: %s" err
  in
  let result =
    List.fold seeds ~init:Int.max_value ~f:(fun acc seed ->
      let location = map_seed seed maps in
      min acc location)
  in
  Fmt.pr "@.==> Folded: %d@." result;
  ()
;;

(* let () = *)
(*   (* Part 2 brute force *) *)
(*   let input = Advent.read_all "./inputs/05-prod.txt" in *)
(*   let input = parse_puzzle input in *)
(*   let seeds, maps = *)
(*     match input with *)
(*     | Ok (seeds, maps) -> seeds, maps *)
(*     | Error err -> Fmt.failwith "Parsing failed: %s" err *)
(*   in *)
(*   let rec get_seeds seeds acc = *)
(*     match seeds with *)
(*     | start :: range :: rest -> (start, range) :: get_seeds rest acc *)
(*     | [] -> acc *)
(*     | _ -> assert false *)
(*   in *)
(*   let seeds = get_seeds seeds [] in *)
(*   let result = *)
(*     List.fold seeds ~init:Int.max_value ~f:(fun acc (start, count) -> *)
(*       Fmt.pr "==== Starting new seed range: %d %d@." start count; *)
(*       List.range start (start + count) *)
(*       |> List.fold ~init:acc ~f:(fun acc seed -> *)
(*         let location = map_seed seed maps in *)
(*         min acc location)) *)
(*   in *)
(*   Fmt.pr "@.==> part 2: %d@." result; *)
(*   () *)
(* ;; *)

let () =
  (* Part 2 real force *)
  let input = Advent.read_all "./inputs/05-prod.txt" in
  let input = parse_puzzle input in
  let seeds, maps =
    match input with
    | Ok (seeds, maps) -> seeds, maps
    | Error err -> Fmt.failwith "Parsing failed: %s" err
  in
  let rec get_seeds seeds acc =
    match seeds with
    | start :: range :: rest -> (start, range) :: get_seeds rest acc
    | [] -> acc
    | _ -> assert false
  in
  let seeds = get_seeds seeds [] in
  let result =
    List.fold seeds ~init:Int.max_value ~f:(fun acc (start, count) ->
      Fmt.pr "==== Starting new seed range: %d %d@." start count;
      Advent.range_seq start (start + count)
      |> Seq.fold_left
           (fun acc seed ->
             let location = map_seed seed maps in
             min acc location)
           acc)
  in
  Fmt.pr "@.==> part 2: %d@." result;
  ()
;;
