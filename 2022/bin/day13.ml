let input = Advent.read_lines "day13.txt"

module Item = struct
  type t =
    | Int of int
    | Lst of t list

  let rec to_string value =
    match value with
    | Int n -> string_of_int n
    | Lst ts -> "[" ^ String.concat "," (List.map to_string ts) ^ "]"
  ;;

  let rec to_int ts =
    match ts with
    | hd :: _ ->
      (match hd with
       | Int n -> n
       | Lst l -> to_int l)
    | _ -> 0
  ;;

  let append self t =
    match self with
    | Int _ -> assert false
    | Lst self -> Lst (self @ [t])
  ;;

  let rec evaluate a b =
    (* list_eval is just so we don't have to pack everything back up into enums every time *)
    let rec list_eval as_ bs_ =
      match as_, bs_ with
      | [], [] -> true
      | [], _ :: _ -> true
      | _ :: _, [] -> false
      | a :: rest_a, b :: rest_b ->
        if a = b then
          list_eval rest_a rest_b
        else
          evaluate a b
    in
    match a, b with
    | Int a, Int b -> a <= b
    | Lst a, Int b -> list_eval a [Int b]
    | Int a, Lst b -> list_eval [Int a] b
    | Lst [], Lst [] -> true
    | Lst [], Lst (_ :: _) -> true
    | Lst (_ :: _), Lst [] -> false
    | Lst (a :: resta), Lst (b :: restb) ->
      if a = b then
        list_eval resta restb
      else
        evaluate a b
  ;;

  let compare a b =
    if a = b then
      0
    else if evaluate a b then
      -1
    else
      1
  ;;

  (* | Lst (a :: rest_a), Lst (b :: rest_b) when a = b *)
  (* | Lst a, Lst b -> ( *)
  (*   let hd_a = Base.List.hd a in *)
  (*   let hd_b = Base.List.hd b in *)
  (*   match hd_a, hd_b with *)
  (*   | None, None -> true *)
  (*   | None, Some _ -> false *)
  (*   | Some Int a, Some Int b when a = b -> evaluate  *)
end

let rest_of str = String.sub str 1 (String.length str - 1)

let parse line =
  let line = String.to_seq line |> List.of_seq in

  let parse_number _ rest =
    let rec inner num rest =
      let hd = List.hd rest in
      match hd with
      | '0' .. '9' -> inner (num ^ Char.escaped hd) (List.tl rest)
      | _ -> num, rest
      (* | x, _ -> num ^ Char.escaped x, rest_of rest *)
    in

    let num, rest = inner "" rest in
    Item.(Int (num |> int_of_string)), rest
  in

  (* let something_else acc rest = *)
  (*   let rec inner acc current rest = *)
  (*     match rest with *)
  (*     | "" -> acc *)
  (*     | "[" ^ rest -> rest *)
  (*   in *)
  (*   assert false *)
  (* in *)
  let rec parse_array acc rest =
    match rest with
    | [] -> acc, rest
    | hd :: rest when hd = ']' -> acc, rest
    | hd :: rest when hd = '[' ->
      let new_list = Item.(Lst []) in
      let new_list, rest = parse_array new_list rest in
      parse_array (Item.append acc new_list) rest
    | hd :: rest when hd = ',' -> parse_array acc rest
    | _ :: _ ->
      let num, rest = parse_number acc rest in
      parse_array (Item.append acc num) rest
  in

  let result, _ = parse_array Item.(Lst []) (List.tl line) in
  result
;;

let part_1 input =
  let rec inner input idx acc =
    match input with
    | l1 :: l2 :: _ :: input ->
      let l1 = parse l1 in
      let l2 = parse l2 in
      let acc =
        acc
        +
        if Item.evaluate l1 l2 then
          idx
        else
          0
      in
      inner input (idx + 1) acc
    | _ -> acc
  in

  let result = inner input 1 0 in
  Format.printf "Part 1: %d\n" result
;;

let part_2 input =
  let inputs =
    List.filter_map
      (fun line ->
        match line with
        | "" -> None
        | line -> Some (parse line))
      input
  in
  let mark_2 = parse "[[2]]" in
  let mark_6 = parse "[[6]]" in
  let inputs = mark_2 :: inputs in
  let inputs = mark_6 :: inputs in
  let sorted = List.sort Item.compare inputs in
  let idx_2 = Base.List.findi ~f:(fun _ a -> a = mark_2) sorted |> Option.get |> fst in
  let idx_6 = Base.List.findi ~f:(fun _ a -> a = mark_6) sorted |> Option.get |> fst in
  Format.printf "Part 2: %d\n" ((idx_2 + 1) * (idx_6 + 1))
;;

let _ = part_1 input
let _ = part_2 input
