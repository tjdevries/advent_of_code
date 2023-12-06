(* let parse_line line = *)
open Core
open Angstrom

let is_digit = function
  | '0' .. '9' -> true
  | _ -> false
;;

let digit =
  take_while1 is_digit >>| Int.of_string <?> "digit: Parse one or more digits"
;;

let whitespace = take_while Char.is_whitespace
let wstring str = whitespace *> string str <* whitespace

module IntSet = Stdlib.Set.Make (Int)

type card =
  { winning : IntSet.t
  ; ours : IntSet.t
  }

(* let x = something()?; *)
let card_parse =
  let* _ = string "Card" *> whitespace *> digit *> wstring ":" in
  let* winning = sep_by1 whitespace digit in
  let* _ = wstring "|" in
  let* ours = sep_by1 whitespace digit in
  return { winning = IntSet.of_list winning; ours = IntSet.of_list ours }
;;

let parse_line line =
  match parse_string ~consume:Prefix card_parse line with
  | Ok res -> res
  | Error err -> Fmt.failwith "haha using exceptions. get rekt haskell: %s" err
;;

let score_line line =
  let card = parse_line line in
  let intersect = IntSet.inter card.winning card.ours in
  IntSet.cardinal intersect
;;

let () =
  let lines = Advent.read_lines "./inputs/04-prod.txt" in
  let score =
    List.fold lines ~init:0 ~f:(fun acc line ->
      match score_line line with
      | 0 -> acc
      | cardinal -> acc + Int.pow 2 (cardinal - 1))
  in
  Fmt.pr "Part 1: (20107) %d@." score;
  ()
;;

let () =
  let lines = Advent.read_lines "./inputs/04-prod.txt" in
  let scores =
    List.fold lines ~init:[] ~f:(fun acc line -> score_line line :: acc)
    |> List.rev
  in
  let multiplers = Array.create ~len:(List.length lines) 1 in
  List.iteri scores ~f:(fun idx score ->
    Advent.range 1 (score + 1) (fun offset ->
      let card = offset + idx in
      multiplers.(card) <- multiplers.(card) + multiplers.(idx)));
  Fmt.pr "Part 2: %d@." (Array.reduce multiplers ~f:( + ) |> Option.value_exn);
  ()
;;
