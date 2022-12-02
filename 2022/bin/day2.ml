let result = Advent.read_lines "day2.txt"

module StringMap = Map.Make (String)

(* Gets called on every row, returns the score value *)
let row s =
  let theirs =
    match String.sub s 0 1 with
    | "A" -> "X"
    | "B" -> "Y"
    | _ -> "Z"
  in
  let ours = String.sub s 2 1 in
  let played =
    match ours with
    | "X" -> 1
    | "Y" -> 2
    | _ -> 3
  in
  let result =
    match theirs, ours with
    | "X", "Y"
    | "Y", "Z"
    | "Z", "X" ->
      6
    | ours, theirs when ours = theirs -> 3
    | _ -> 0
  in
  played + result
;;

let rec score problem reducer acc =
  match problem with
  | [] -> acc
  | hd :: tail -> score tail reducer (reducer hd + acc)
;;

(* Part 1  *)
let () = print_endline "Part 1"
let () = score result row 0 |> string_of_int |> print_endline

(* Part 2 *)

(* Rock A *)
(* Paper B *)
(* Scissors C *)
let win = List.to_seq [ "A", "B"; "B", "C"; "C", "A" ] |> StringMap.of_seq
let lose = List.to_seq [ "A", "C"; "B", "A"; "C", "B" ] |> StringMap.of_seq
let played_points = List.to_seq [ "A", 1; "B", 2; "C", 3 ] |> StringMap.of_seq
let result_points = List.to_seq [ "X", 0; "Y", 3; "Z", 6 ] |> StringMap.of_seq

let part2 s =
  let theirs = String.sub s 0 1 in
  let outcome = String.sub s 2 1 in
  let our_move =
    match outcome with
    | "X" -> StringMap.find theirs lose
    | "Y" -> theirs
    | _ -> StringMap.find theirs win
  in
  StringMap.find outcome result_points + StringMap.find our_move played_points
;;

let () = print_endline "Part 2"
let () = score result part2 0 |> string_of_int |> print_endline

module RPS = struct
  type t =
    | Rock
    | Paper
    | Scissors

  let of_string = function
    | "A" -> Rock
    | "B" -> Paper
    | "C" -> Scissors
    | _ -> assert false
  ;;

  let to_string = function
    | Rock -> "A"
    | Paper -> "B"
    | Scissors -> "C"
  ;;

  let compare a b = compare (to_string a) (to_string b)
end

module RPSMap = Map.Make (RPS)

let win =
  List.to_seq [ RPS.Rock, RPS.Paper; RPS.Paper, RPS.Scissors; RPS.Scissors, RPS.Rock ]
  |> RPSMap.of_seq
;;

let lose =
  List.to_seq [ RPS.Rock, RPS.Scissors; RPS.Paper, RPS.Rock; RPS.Scissors, RPS.Paper ]
  |> RPSMap.of_seq
;;

let played_points =
  List.to_seq [ RPS.Rock, 1; RPS.Paper, 2; RPS.Scissors, 3 ] |> RPSMap.of_seq
;;

let result_points = List.to_seq [ "X", 0; "Y", 3; "Z", 6 ] |> StringMap.of_seq

(* let conv s = match s with *)
(*     | "X" -> Rock *)
(*     | "Y" -> Paper *)
(*     | "Z" -> Scissors *)

let part2 s =
  let theirs = String.sub s 0 1 |> RPS.of_string in
  let outcome = String.sub s 2 1 in
  let our_move =
    match outcome with
    | "X" -> RPSMap.find theirs lose
    | "Y" -> theirs
    | "Z" -> RPSMap.find theirs win
    | _ -> assert false
  in
  StringMap.find outcome result_points + RPSMap.find our_move played_points
;;

let () = print_endline "Part 2"
let () = score result part2 0 |> string_of_int |> print_endline
