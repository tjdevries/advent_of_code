let result = Advent.read_lines "day4.txt"
let split_once = Advent.split_once

module Elf = struct
  type t = {
    start: int;
    finish: int;
  }

  let of_string s =
    let start, finish = split_once '-' s in
    let start = int_of_string start in
    let finish = int_of_string finish in
    { start; finish }
  ;;

  let subset left right = left.start <= right.start && left.finish >= right.finish
  let between start finish value = start <= value && value <= finish

  let overlaps left right =
    between left.start left.finish right.start
    || between left.start left.finish right.finish
  ;;
end

let part1 acc row =
  let score row =
    let left, right = split_once ',' row in
    let left = Elf.of_string left in
    let right = Elf.of_string right in
    (Elf.subset left right || Elf.subset right left) |> Bool.to_int
  in

  acc + score row
;;

let _ = print_endline "\nPart 1:"
let _ = List.fold_left part1 0 result |> print_int

let part2 acc row =
  let score row =
    let left, right = split_once ',' row in
    let left = Elf.of_string left in
    let right = Elf.of_string right in
    (Elf.overlaps left right || Elf.overlaps right left) |> Bool.to_int
  in

  acc + score row
;;

let _ = print_endline "\nPart 2:"
let _ = List.fold_left part2 0 result |> print_int
