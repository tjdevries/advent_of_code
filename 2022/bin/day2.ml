let result = Advent.read_lines "day2.txt"

module StringMap = Map.Make (String)

let score problem reducer =
  let rec score_helper problem reducer acc =
    match problem with
    | [] -> acc
    | hd :: tail -> score_helper tail reducer (reducer hd + acc)
  in
  score_helper problem reducer 0
;;

(* Part 1  *)

(* Gets called on every row, returns the score value *)
let part1 s =
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
     |"Y", "Z"
     |"Z", "X" ->
      6
    | ours, theirs when ours = theirs -> 3
    | _ -> 0
  in
  played + result
;;

let () = print_endline "Part 1"
let () = score result part1 |> string_of_int |> print_endline

(* Part 2 *)

(* Rock A *)
(* Paper B *)
(* Scissors C *)

(* Turn a list of pairs into a map *)
let str_map l = List.to_seq l |> StringMap.of_seq
let win = str_map ["A", "B"; "B", "C"; "C", "A"]
let lose = str_map ["A", "C"; "B", "A"; "C", "B"]
let played_points = str_map ["A", 1; "B", 2; "C", 3]
let result_points = str_map ["X", 0; "Y", 3; "Z", 6]

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
let () = score result part2 |> string_of_int |> print_endline

(* Part 2: Better Solution *)

let identity a = a

let hd l =
  match l with
  | [] -> None
  | hd :: _ -> Some hd
;;

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

let rps_map s = List.to_seq s |> RPSMap.of_seq

module Action = struct
  type t =
    | Loss
    | Draw
    | Win

  let of_string = function
    | "X" -> Ok Loss
    | "Y" -> Ok Draw
    | "Z" -> Ok Win
    | _ -> Error "Unknown"
  ;;

  let to_string = function
    | Loss -> "X"
    | Draw -> "Y"
    | Win -> "Z"
  ;;

  let compare a b = compare (to_string a) (to_string b)
end

module ActionMap = Map.Make (Action)

let action_map s = List.to_seq s |> ActionMap.of_seq

(* Maps for doing what move we need to do *)
let lose = rps_map [RPS.Rock, RPS.Scissors; RPS.Paper, RPS.Rock; RPS.Scissors, RPS.Paper]
let win = rps_map [RPS.Rock, RPS.Paper; RPS.Paper, RPS.Scissors; RPS.Scissors, RPS.Rock]

(* Maps for points *)
let played_points = rps_map [RPS.Rock, 1; RPS.Paper, 2; RPS.Scissors, 3]
let result_points = action_map [Action.Loss, 0; Action.Draw, 3; Action.Win, 6]

let typed_part2 s =
  let theirs = String.sub s 0 1 |> RPS.of_string in
  let outcome = String.sub s 2 1 |> Action.of_string |> Result.get_ok in
  let our_move =
    match outcome with
    | Loss -> RPSMap.find theirs lose
    | Draw -> theirs
    | Win -> RPSMap.find theirs win
  in
  ActionMap.find outcome result_points + RPSMap.find our_move played_points
;;

let () = print_endline "Part 2"
let () = score result typed_part2 |> string_of_int |> print_endline
