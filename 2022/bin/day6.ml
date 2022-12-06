let result = Advent.read_lines "day6.txt"

let part1 row =
  let rec find a b c d row idx =
    match a, b, c, d with
    | a, b, c, d when a != b && a != c && a != d && b != c && b != d && c != d -> idx
    | _ ->
      (match row with
       | [] -> assert false
       | hd :: rest -> find b c d hd rest (idx + 1))
  in

  let result =
    match row with
    | a :: b :: c :: d :: rest -> find a b c d rest 4
    | _ -> assert false
  in

  print_int result
;;

module CharSet = Set.Make (Char)

let rec fold_x list f acc n =
  if n = 0 then
    Some acc
  else (
    match f (List.hd list) acc with
    | `Cancel -> None
    | `Continue acc -> fold_x (List.tl list) f acc (n - 1)
  )
;;

let solve count row =
  let f value acc =
    let start = CharSet.cardinal acc in
    let acc = CharSet.add value acc in
    let final = CharSet.cardinal acc in
    if start == final then
      `Cancel
    else
      `Continue acc
  in
  let make_set n row = fold_x row f CharSet.empty n in
  let rec find n list idx =
    match make_set n list with
    | None -> find n (List.tl list) (idx + 1)
    | _ -> idx
  in
  count + find count row 0
;;

let row = List.hd result |> String.to_seq |> List.of_seq

(* Old Part 1 Solution *)
let _ = part1 row

(* Better part 2 solution *)
let _ = solve 4 row |> Format.printf "\nPart 1: %d"
let _ = solve 14 row |> Format.printf "\nPart 2: %d"
