let input = Advent.read_lines "day10.txt"

type instruction =
  | Noop
  | AddCycle of int

let instr_of_string str =
  if str = "noop" then
    Noop
  else (
    let _, count = Advent.split_once ' ' str in
    AddCycle (int_of_string count)
  )
;;

module State = struct
  type t = {
    cycle: int;
    x: int;
    signal: int;
  }

  let power state = state.cycle * state.x
  let applicable_cycle x = (x - 20) mod 40 = 0

  let calculate_signal state =
    state.signal
    +
    if applicable_cycle state.cycle then
      power state
    else
      0
  ;;

  let overlaps state =
    let cycle = (state.cycle - 1) mod 40 in
    abs (cycle - state.x) <= 1
  ;;

  let to_string state = Format.sprintf "state: %d %d %d" state.cycle state.x state.signal
end

let apply_instruction inst state =
  match inst with
  | Noop ->
    State.{ state with cycle = state.cycle + 1; signal = State.calculate_signal state }
  | AddCycle x ->
    let state =
      State.{ state with cycle = state.cycle + 1; signal = State.calculate_signal state }
    in
    let state =
      State.
        {
          x = state.x + x;
          cycle = state.cycle + 1;
          signal = State.calculate_signal state;
        }
    in
    state
;;

let part_1 input =
  let folder state row =
    let instr = instr_of_string row in
    apply_instruction instr state
  in

  List.fold_left folder State.{ cycle = 1; x = 1; signal = 0 } input
;;

let state = part_1 input
let _ = Format.printf "Part 1: %s\n" (State.to_string state)

let part_2 input =
  let crdt = Array.make 240 '_' in
  let apply_overlap state = if State.overlaps state then crdt.(state.cycle - 1) <- '#' in
  let apply_instruction inst state =
    match inst with
    | Noop ->
      apply_overlap state;
      let state = State.{ state with cycle = state.cycle + 1 } in
      state
    | AddCycle x ->
      apply_overlap state;
      let state = State.{ state with cycle = state.cycle + 1 } in
      apply_overlap state;
      let state = State.{ state with cycle = state.cycle + 1; x = state.x + x } in
      state
  in

  let f state row =
    let instr = instr_of_string row in
    apply_instruction instr state
  in

  let _ = List.fold_left f State.{ cycle = 1; x = 1; signal = 0 } input in
  crdt
;;

let crdt = part_2 input

let _ =
  for i = 0 to 5 do
    for j = 0 to 39 do
      print_char crdt.((i * 40) + j)
    done;
    print_newline ()
  done
;;
