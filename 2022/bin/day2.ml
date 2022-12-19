let result = Advent.read_lines "day2.txt"

module StringMap = Map.Make (String)

let score problem scorer =
  let rec score_helper problem scorer acc =
    match problem with
    | [] -> acc
    | hd :: tail -> score_helper tail scorer (scorer hd + acc)
  in
  score_helper problem scorer 0
;;

(* Part 1  *)

(* Gets called on every row, returns the score value *)
let part1 s =
  let theirs =
    match String.sub s 0 1 with
    | "A" -> "X"
    | "B" -> "Y"
    | "C" -> "Z"
    | _ -> assert false
  in
  let ours = String.sub s 2 1 in
  let played =
    match ours with
    | "X" -> 1
    | "Y" -> 2
    | "Z" -> 3
    | _ -> assert false
  in
  let result =
    match theirs, ours with
    | "X", "Y"
     |"Y", "Z"
     |"Z", "X" ->
      6
    | theirs, ours when theirs = ours -> 3
    | _ -> 0
  in
  played + result
;;

let () = Format.sprintf "Part 1: %d" (score result part1) |> print_endline

(* Part 2: Better Solution *)

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

  let get_lose mv =
    match mv with
    | Rock -> Scissors
    | Paper -> Rock
    | Scissors -> Paper
  ;;

  let get_win mv =
    match mv with
    | Rock -> Paper
    | Paper -> Scissors
    | Scissors -> Rock
  ;;

  let points mv =
    match mv with
    | Rock -> 1
    | Paper -> 2
    | Scissors -> 3
  ;;
end

module Action = struct
  type t =
    | Loss
    | Draw
    | Win

  let of_string = function
    | "X" -> Loss
    | "Y" -> Draw
    | "Z" -> Win
    | _ -> assert false
  ;;

  let points mv =
    match mv with
    | Loss -> 0
    | Draw -> 3
    | Win -> 6
  ;;
end

let part2 s =
  let theirs = String.sub s 0 1 |> RPS.of_string in
  let outcome = String.sub s 2 1 |> Action.of_string in
  let our_move =
    match outcome with
    | Loss -> RPS.get_lose theirs
    | Draw -> theirs
    | Win -> RPS.get_win theirs
  in
  Action.points outcome + RPS.points our_move
;;

let () = Format.sprintf "Part 2: %d" (score result part2) |> print_endline
