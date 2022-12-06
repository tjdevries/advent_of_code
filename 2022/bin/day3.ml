let result = Advent.read_lines "day3.txt"

module CharSet = Set.Make (Char)

let to_char_set str = String.to_seq str |> CharSet.of_seq

let score_char c =
  let code = Char.code c in
  match c with
  | 'A' .. 'Z' -> code - 38
  | 'a' .. 'z' -> code - 96
  | _ -> assert false
;;

let score_part1 acc row =
  let length = String.length row in
  let left = String.sub row 0 (length / 2) |> to_char_set in
  let right = String.sub row (length / 2) (length / 2) |> to_char_set in
  let c = CharSet.inter left right |> CharSet.choose in
  acc + score_char c
;;

let part2 rows =
  let score a b c =
    let a = to_char_set a in
    let b = to_char_set b in
    let c = to_char_set c in
    let badge = CharSet.inter a b |> CharSet.inter c |> CharSet.choose in
    score_char badge
  in

  let rec fold_left3 f rows acc =
    match rows with
    | [] -> acc
    | a :: b :: c :: rest -> (fold_left3 [@tailcall]) f rest (acc + f a b c)
    | _ -> assert false
  in

  fold_left3 score rows 0
;;

let _ = print_string "Part 1\n"
let _ = List.fold_left score_part1 0 result |> print_int
let _ = print_string "\nPart 2\n"
let _ = part2 result |> print_int
let _ = print_newline ()
