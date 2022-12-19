(* let input = Advent.read_lines "day8.txt" *)
let input = Advent.read_lines "day8.prod"

module CoordSet = Set.Make (struct
  type t = int * int

  let compare = Stdlib.compare
end)

let part_1 input =
  let size = List.hd input |> String.length in
  let matrix_n = Array.init size (fun _ -> Array.make size 0) in
  let transform_n row col = row, col in
  let matrix_s = Array.init size (fun _ -> Array.make size 0) in
  let transform_s row col = size - 1 - row, col in
  let matrix_e = Array.init size (fun _ -> Array.make size 0) in
  let transform_e row col = col, row in
  let matrix_w = Array.init size (fun _ -> Array.make size 0) in
  let transform_w row col = col, size - 1 - row in
  let row_iter row col ch =
    (* Something *)
    let value = int_of_char ch - 48 in
    matrix_n.(row).(col) <- value;
    matrix_s.(size - 1 - row).(col) <- value;
    matrix_e.(col).(row) <- value;
    matrix_w.(size - 1 - col).(row) <- value
  in
  List.iteri (fun row line -> String.iteri (row_iter row) line) input;

  let coords = ref CoordSet.empty in
  let update_coords coords matrix transform =
    let maxs = Array.make size (-1) in
    let row_iter row col height =
      let max_height = maxs.(col) in
      if height > max_height then (
        (* Bigger height, so track and update *)
        coords := CoordSet.add (transform row col) !coords;
        maxs.(col) <- height
      )
    in
    Array.iteri (fun rowi row -> Array.iteri (row_iter rowi) row) matrix
  in
  update_coords coords matrix_n transform_n;
  update_coords coords matrix_s transform_s;
  update_coords coords matrix_e transform_e;
  update_coords coords matrix_w transform_w;
  Format.printf "Count: %d\n" (CoordSet.cardinal !coords)
;;

(* Advent.print_listof_ints (Array.to_seq matrix.(1) |> List.of_seq) *)

let _ = part_1 input

module CoordMap = Map.Make (struct
  type t = int * int

  let compare = Stdlib.compare
end)

let part_2 input =
  let size = List.hd input |> String.length in
  let matrix = Array.init size (fun _ -> Array.make size 0) in
  let row_iter row col ch =
    (* Something *)
    let value = int_of_char ch - 48 in
    matrix.(row).(col) <- value
  in
  List.iteri (fun row line -> String.iteri (row_iter row) line) input;

  let rec find_dist acc height row col dir_row dir_col =
    let row_new = row + (dir_row * acc) in
    let col_new = col + (dir_col * acc) in
    if row = 0 || col = 0 || row = size - 1 || col = size - 1 then
      0
    else if row_new < 0 || col_new < 0 || row_new >= size || col_new >= size then
      acc - 1
    else if height <= matrix.(row_new).(col_new) then
      acc
    else
      find_dist (acc + 1) height row col dir_row dir_col
  in

  let maxscore = ref 0 in
  let scenic_score matrix =
    let row_iter rowi coli height =
      let score = find_dist 1 height rowi coli 1 0 in
      let score = score * find_dist 1 height rowi coli (-1) 0 in
      let score = score * find_dist 1 height rowi coli 0 1 in
      let score = score * find_dist 1 height rowi coli 0 (-1) in

      maxscore := max score !maxscore
    in

    Array.iteri
      (fun rowi row -> Array.iteri (fun coli height -> row_iter rowi coli height) row)
      matrix
    (* Array.fold_left (fun rowi row -> Array.iteri (row_iter rowi) row) 0 matrix *)
  in
  scenic_score matrix;

  Format.printf "Part 2: %d\n" !maxscore
;;

let _ = part_2 input
