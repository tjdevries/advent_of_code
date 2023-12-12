open Core

type direction =
  | Left
  | Right
[@@deriving show]

let parse_direction =
  let open Advent.A in
  let* directions = many @@ choice [ char 'R'; char 'L' ] in
  return
    (directions
     |> List.map ~f:(function
       | 'R' -> Right
       | 'L' -> Left
       | _ -> assert false))
;;

(* Infinite sequence of directions, not sure if it's good or not *)
let directions_to_sequence directions =
  let len = List.length directions in
  Seq.unfold
    (fun idx ->
      let value = List.nth_exn directions (idx mod len) in
      Some (value, idx + 1))
    0
;;

type node =
  { name : string
  ; left : string
  ; right : string
  }
[@@deriving show]

module StringMap = Map.Make (String)

let parse_line =
  let open Advent.A in
  let* name = take_while Char.is_alphanum in
  let* _ = string " = (" in
  let* left = take_while Char.is_alphanum in
  let* _ = string ", " in
  let* right = take_while Char.is_alphanum in
  let* _ = string ")" in
  return { name; left; right }
;;

let parse_file =
  let open Advent.A in
  let* directions = parse_direction in
  let* _ = string "\n\n" in
  let* nodes = sep_by whitespace parse_line in
  let* _ = whitespace in
  return (directions, nodes)
;;

(* let () = *)
(*   let lines = Advent.read_all "inputs/08-test.txt" in *)
(*   let directions, nodes = *)
(*     Angstrom.parse_string ~consume:All parse_file lines |> Result.ok_or_failwith *)
(*   in *)
(*   Fmt.pr "@.directions: %a@." (Fmt.list pp_direction) directions; *)
(*   Fmt.pr "@.nodes: %a@." (Fmt.list pp_node) nodes; *)
(*   let nodes = *)
(*     List.fold nodes ~init:StringMap.empty ~f:(fun map node -> *)
(*       Map.set map ~key:node.name ~data:(node.left, node.right)) *)
(*   in *)
(*   let start = Map.find_exn nodes "AAA" in *)
(*   let seq = directions_to_sequence directions in *)
(*   let rec solve (left, right) seq acc = *)
(*     match Seq.uncons seq with *)
(*     | Some (Left, seq) when String.(left = "ZZZ") -> acc *)
(*     | Some (Right, seq) when String.(right = "ZZZ") -> acc *)
(*     | Some (Left, seq) -> solve (Map.find_exn nodes left) seq (acc + 1) *)
(*     | Some (Right, seq) -> solve (Map.find_exn nodes right) seq (acc + 1) *)
(*     | None -> assert false *)
(*   in *)
(*   let result = solve start seq 1 in *)
(*   Fmt.pr "@.=> Part 1: %d@." result *)
(* ;; *)

let string_endswith s ch =
  let len = String.length s in
  let last = String.get s (len - 1) in
  Char.(last = ch)
;;

let () =
  let lines = Advent.read_all "inputs/08-test.txt" in
  let directions, nodes =
    Angstrom.parse_string ~consume:All parse_file lines |> Result.ok_or_failwith
  in
  Fmt.pr "@.directions: %a@." (Fmt.list pp_direction) directions;
  Fmt.pr "@.nodes: %a@." (Fmt.list pp_node) nodes;
  let nodes =
    List.fold nodes ~init:StringMap.empty ~f:(fun map node ->
      Map.set map ~key:node.name ~data:(node.left, node.right))
  in
  let starting =
    Map.filter_keys nodes ~f:(fun name -> string_endswith name 'A')
    |> Map.to_alist
    |> List.map ~f:fst
  in
  List.iter starting ~f:(Fmt.pr "NAME: %s@.");
  let seq = directions_to_sequence directions in
  let rec solve seq remaining acc =
    match remaining, Seq.uncons seq with
    | remaining, _
      when List.for_all remaining ~f:(fun name -> string_endswith name 'Z') ->
      acc
    | _, Some (Left, seq) ->
      let remaining =
        List.map remaining ~f:(fun name -> Map.find_exn nodes name |> fst)
      in
      solve seq remaining (acc + 1)
    | _, Some (Right, seq) ->
      let remaining =
        List.map remaining ~f:(fun name -> Map.find_exn nodes name |> snd)
      in
      solve seq remaining (acc + 1)
    | _, None -> assert false
  in
  let result = solve seq starting 0 in
  Fmt.pr "@.Part 2: %d@." result
;;
(* let seq = directions_to_sequence directions in *)
(* let rec solve (left, right) seq acc = *)
(*   match Seq.uncons seq with *)
(*   | Some (Left, seq) when String.(left = "ZZZ") -> acc *)
(*   | Some (Right, seq) when String.(right = "ZZZ") -> acc *)
(*   | Some (Left, seq) -> solve (Map.find_exn nodes left) seq (acc + 1) *)
(*   | Some (Right, seq) -> solve (Map.find_exn nodes right) seq (acc + 1) *)
(*   | None -> assert false *)
(* in *)
(* let result = solve start seq 1 in *)
(* Fmt.pr "@.=> Part 2: %d@." result *)
