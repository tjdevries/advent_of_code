open Core

let line_difference numbers =
  let len = List.length numbers in
  Advent.range_seq 0 (len - 2)
  |> Seq.fold_left
       (fun acc idx ->
         let right = List.nth_exn numbers (idx + 1) in
         let left = List.nth_exn numbers idx in
         (right - left) :: acc)
       []
  |> List.rev
;;

let solve_line numbers =
  let numbers = String.split numbers ~on:' ' |> List.map ~f:Int.of_string in
  let rec aux numbers something =
    let differences = line_difference numbers in
    if List.for_all differences ~f:(Int.equal 0)
    then something
    else aux differences (List.last_exn differences :: something)
  in
  aux numbers [ List.last_exn numbers ]
;;

let () =
  let lines = Advent.read_lines "inputs/09-prod.txt" in
  List.iter lines ~f:print_endline;
  let result =
    List.fold lines ~init:0 ~f:(fun acc line ->
      acc + List.reduce_exn (solve_line line) ~f:( + ))
  in
  Fmt.pr "RESULT: %d@." result;
  ()
;;
