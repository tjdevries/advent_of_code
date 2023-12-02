open Core

let () =
  let lines = Advent.read_lines "./inputs/02-prod.txt" in
  let conditions =
    [ 12, Re.Perl.compile_pat "(\\d+) red"
    ; 13, Re.Perl.compile_pat "(\\d+) green"
    ; 14, Re.Perl.compile_pat "(\\d+) blue"
    ]
  in
  let is_valid_condition line (number, condition) =
    let matches = Re.all condition line in
    List.find matches ~f:(fun m ->
      let group_matches = Re.Group.get_opt m 1 in
      match group_matches with
      | Some m when Int.of_string m > number -> true
      | _ -> false)
    |> Option.is_some
  in
  List.foldi lines ~init:0 ~f:(fun idx acc line ->
    let invalid = List.filter conditions ~f:(is_valid_condition line) in
    acc + if List.length invalid = 0 then idx + 1 else 0)
  |> Fmt.pr "@.Part 1: (2207) %d@."
;;

let () =
  let lines = Advent.read_lines "./inputs/02-prod.txt" in
  let searches =
    [ Re.Perl.compile_pat "(\\d+) red"
    ; Re.Perl.compile_pat "(\\d+) green"
    ; Re.Perl.compile_pat "(\\d+) blue"
    ]
  in
  (* Takes a line and gets the max for each color indvidiually *)
  let get_max_conditions line condition =
    let matches = Re.all condition line in
    List.fold matches ~init:1 ~f:(fun acc m ->
      match Re.Group.get_opt m 1 with
      | Some num when Int.of_string num > acc -> Int.of_string num
      | _ -> acc)
  in
  List.foldi lines ~init:0 ~f:(fun idx acc line ->
    let maximums = List.map searches ~f:(get_max_conditions line) in
    let power = List.fold maximums ~init:1 ~f:( * ) in
    acc + power)
  |> Fmt.pr "Part 2: (62241) %d@."
;;
