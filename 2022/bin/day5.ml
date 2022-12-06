let result = Advent.read_lines "day5.txt"
let empty = ' '

let print_tops stacks =
  Array.iter (fun stack -> Stack.top stack |> print_char) stacks;
  print_newline ()
;;

let push_row_on_stacks row stacks =
  let transform_idx idx = (idx * 4) + 1 in
  let f idx stack =
    match transform_idx idx |> String.get row with
    | s when s = empty -> ()
    | s -> Stack.push s stack
  in
  Array.iteri f stacks
;;

module Move = struct
  type t = {
    amount: int;
    src: int;
    dest: int;
  }

  let of_string move =
    let split = String.split_on_char ' ' move |> Array.of_list in
    let amount = split.(1) |> int_of_string in
    let src = (split.(3) |> int_of_string) - 1 in
    let dest = (split.(5) |> int_of_string) - 1 in
    { amount; src; dest }
  ;;
end

let flip = Base.Fn.flip

let move_part_1 stacks move =
  let move = Move.of_string move in
  for _ = 0 to move.amount - 1 do
    Stack.pop stacks.(move.src) |> flip Stack.push stacks.(move.dest)
  done
;;

let move_part_2 stacks move =
  let move = Move.of_string move in
  let arr = Array.make move.amount empty in
  for idx = 0 to move.amount - 1 do
    Stack.pop stacks.(move.src) |> Array.set arr idx
  done;

  for idx = 0 to move.amount - 1 do
    Stack.push arr.(move.amount - idx - 1) stacks.(move.dest)
  done
;;

let find_number_row input =
  Base.List.findi ~f:(fun _ s -> String.get s 1 == '1') input |> Option.get
;;

let solve f input =
  let rows, columns = find_number_row input in
  let num_stacks = (1 + String.length columns) / 4 in
  let stacks = Array.init num_stacks (fun _ -> Stack.create ()) in
  for i = rows - 1 downto 0 do
    push_row_on_stacks (List.nth input i) stacks
  done;
  let moves = Base.List.drop input (rows + 2) in
  List.iter (f stacks) moves;
  stacks
;;

let _ = solve move_part_1 result |> print_tops
let _ = solve move_part_2 result |> print_tops
