open Core

(*
   Time:      7  15   30
   Distance:  9  40  200

   Time:        59     70     78     78
   Distance:   430   1218   1213   1276 *)
let score time distance hold =
  let remaining = time - hold in
  remaining * hold > distance
;;

let () =
  (* let cases = [ 7, 9; 15, 40; 30, 200 ] in *)
  (* let cases = [ 59, 430; 70, 1218; 78, 1213; 78, 1276 ] in *)
  let cases = [ 59707878, 430121812131276 ] in
  let result =
    List.fold cases ~init:1 ~f:(fun acc (time, distance) ->
      let passes = score time distance in
      acc * (Advent.range_seq 1 time |> Seq.filter passes |> Seq.length))
  in
  Fmt.pr "@.Part 1: %d@." result
;;
