let input = Advent.read_lines "day11.txt"

module Monkey = struct
  type t = {
    mutable inspected: int;
    mutable items: int list;
    op: int -> int;
    test: int;
    if_true: int;
    if_false: int;
  }

  let create start op test if_true if_false =
    let start_colon = String.index start ':' + 1 in
    let numbers = String.sub start start_colon (String.length start - start_colon) in
    let items =
      String.split_on_char ',' numbers
      |> List.map (fun s -> String.trim s |> int_of_string)
    in
    let operator =
      match String.get op 23 with
      | '+' -> ( + )
      | '*' -> ( * )
      | _ -> assert false
    in
    let op =
      match String.sub op 25 (String.length op - 25) with
      | "old" -> (fun old -> operator old old)
      | int ->
        let int = int_of_string int in
        (fun old -> operator old int)
    in
    let test = String.sub test 21 (String.length test - 21) |> int_of_string in
    let if_true =
      String.get if_true (String.length if_true - 1) |> Char.escaped |> int_of_string
    in
    let if_false =
      String.get if_false (String.length if_false - 1) |> Char.escaped |> int_of_string
    in

    { items; op; test; if_true; if_false; inspected = 0 }
  ;;

  let inspect monkey =
    (* Update the state, sorry for mutating *)
    let items = monkey.items in
    monkey.inspected <- monkey.inspected + List.length items;
    monkey.items <- [];

    let inspect_one_item actions item =
      let worry = monkey.op item in
      let worry = worry / 3 in
      if worry mod monkey.test = 0 then
        (monkey.if_true, worry) :: actions
      else
        (monkey.if_false, worry) :: actions
    in
    List.fold_left inspect_one_item [] items |> List.rev
  ;;

  let inspect_2 monkey lcm =
    (* Update the state, sorry for mutating *)
    let items = monkey.items in
    monkey.inspected <- monkey.inspected + List.length items;
    monkey.items <- [];

    let inspect_one_item actions item =
      let worry = monkey.op item in
      let worry = worry mod lcm in
      if worry mod monkey.test = 0 then
        (monkey.if_true, worry) :: actions
      else
        (monkey.if_false, worry) :: actions
    in
    List.fold_left inspect_one_item [] items |> List.rev
  ;;

  let to_string m =
    Format.sprintf
      "Monkey(items=%d, %d, %d, %d, inspected=%d)"
      (List.length m.items)
      m.test
      m.if_true
      m.if_false
      m.inspected
  ;;
end

let parse input =
  let rec inner acc input =
    match input with
    | "" :: rest -> inner acc rest
    | _ :: starting :: operating :: test :: if_true :: if_false :: rest ->
      let monkey = Monkey.create starting operating test if_true if_false in
      inner (acc @ [monkey]) rest
    | _ -> acc
  in

  let parsed = inner [] input in
  Format.printf "Number of monkeys: %d\n" (List.length parsed);

  let parsed = Array.of_list parsed in
  for _ = 1 to 20 do
    for idx = 0 to Array.length parsed - 1 do
      let actions = Monkey.inspect parsed.(idx) in
      List.iter
        (fun (monkey, item) -> parsed.(monkey).items <- parsed.(monkey).items @ [item])
        actions
    done
  done;

  Array.iter (fun m -> Monkey.to_string m |> print_endline) parsed;
  Array.sort (fun a b -> -1 * Monkey.(Int.compare a.inspected b.inspected)) parsed;
  let most = parsed.(0).inspected in
  let next = parsed.(1).inspected in
  Format.sprintf "%d * %d = %d\n" most next (most * next) |> print_endline
;;

let _ = parse input

let parse_2 input =
  let rec inner acc input =
    match input with
    | "" :: rest -> inner acc rest
    | _ :: starting :: operating :: test :: if_true :: if_false :: rest ->
      let monkey = Monkey.create starting operating test if_true if_false in
      inner (acc @ [monkey]) rest
    | _ -> acc
  in

  let parsed = inner [] input in
  Format.printf "Number of monkeys: %d\n" (List.length parsed);

  (* ACristofferS *)
  (* That's not true, a won't be congruent to b in all cases, but this will
     work for when the remainder is zero, that is, if x mod a*b*c == 0 then x
     mod a == 0 and x mod b == 0 and x mod c == 0. They will be different from
     zero at the same time, but won't have the same numerical value. *)
  let lcm = List.fold_left (fun acc mk -> Monkey.(acc * mk.test)) 1 parsed in

  let parsed = Array.of_list parsed in
  for _ = 1 to 10000 do
    for idx = 0 to Array.length parsed - 1 do
      let actions = Monkey.inspect_2 parsed.(idx) lcm in
      List.iter
        (fun (monkey, item) -> parsed.(monkey).items <- parsed.(monkey).items @ [item])
        actions
    done
  done;

  Array.iter (fun m -> Monkey.to_string m |> print_endline) parsed;
  Array.sort (fun a b -> -1 * Monkey.(Int.compare a.inspected b.inspected)) parsed;
  let most = parsed.(0).inspected in
  let next = parsed.(1).inspected in
  Format.sprintf "%d * %d = %d\n" most next (most * next) |> print_endline
;;

let _ = parse_2 input
