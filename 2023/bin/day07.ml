open Core

let score_counts = function
  | [ _ ] -> 7
  | [ 4; _ ] -> 6
  | [ 3; _ ] -> 5
  | [ 3; _; _ ] -> 4
  | [ 2; _; _ ] -> 3
  | [ 2; _; _; _ ] -> 2
  | _ -> 1
;;

module type SCORER = sig
  val score : string -> int
  val map : char -> int
end

module Part1 : SCORER = struct
  let score cards =
    Advent.char_count cards
    |> Map.to_alist
    |> List.map ~f:snd
    |> List.sort ~compare:(fun a b -> compare b a)
    |> score_counts
  ;;

  let map = function
    | 'A' -> 14
    | 'K' -> 13
    | 'Q' -> 12
    | 'J' -> 11
    | 'T' -> 10
    | ch -> Int.of_string (String.of_char ch)
  ;;
end

module Part2 : SCORER = struct
  let score cards =
    let counts =
      Advent.char_count cards
      |> Map.to_alist
      |> List.sort ~compare:(fun (_, a) (_, b) -> Int.compare b a)
    in
    let jokers, counts =
      List.partition_map counts ~f:(fun (card, count) ->
        match card with
        | 'J' -> Either.First count
        | _ -> Either.Second count)
    in
    let jokers = List.hd jokers |> Option.value ~default:0 in
    match jokers, counts with
    | 5, _ -> 7
    | jokers, hd :: tail -> score_counts ((hd + jokers) :: tail)
    (* 0, [] is impossible *)
    | _ -> assert false
  ;;

  let map = function
    | 'J' -> 1
    | 'A' -> 14
    | 'K' -> 13
    | 'Q' -> 12
    | 'T' -> 10
    | ch -> Int.of_string (String.of_char ch)
  ;;
end

module Hand = struct
  type t =
    { cards : string
    ; sorting : int list
    ; bid : int
    ; score : int
    }
  [@@deriving show]

  let card_scores cards card_to_int =
    cards |> String.to_list |> List.map ~f:card_to_int
  ;;

  let compare a b =
    match compare a.score b.score with
    | 0 -> List.compare Int.compare a.sorting b.sorting
    | cmp -> cmp
  ;;

  let make (module S : SCORER) s =
    let cards, bid = Advent.split_once ' ' s in
    let bid = Int.of_string bid in
    { cards; bid; score = S.score cards; sorting = card_scores cards S.map }
  ;;
end

let solve file scorer =
  let lines = Advent.read_lines file in
  let hands = List.map lines ~f:(Hand.make scorer) in
  let hands = List.sort hands ~compare:Hand.compare in
  List.foldi hands ~init:0 ~f:(fun idx acc hand -> acc + (hand.bid * (idx + 1)))
;;

let filename = "inputs/07-prod.txt"
let () = solve filename (module Part1) |> Fmt.pr "Part 1: %d@."
let () = solve filename (module Part2) |> Fmt.pr "Part 2: %d@."
