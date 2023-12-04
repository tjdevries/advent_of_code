open Core
module Set = Stdlib.Set

type symbol =
  { row : int
  ; col : int
  ; ch : char
  }
[@@deriving show]

let get_symbols_from_line line row =
  let characters = String.to_list line in
  List.filter_mapi characters ~f:(fun col ch ->
    match ch with
    | '0' .. '9' -> None
    | '.' -> None
    | ch -> Some { row; col; ch })
;;

module PartNumber = struct
  type t =
    { row : int
    ; col_start : int
    ; col_end : int
    ; value : int
    }
  [@@deriving show, ord]

  let collides part (symbol : symbol) =
    List.find Advent.directions ~f:(fun (x, y) ->
      let row = symbol.row + y in
      let col = symbol.col + x in
      part.row = row && part.col_end >= col && part.col_start <= col)
    |> Option.is_some
  ;;
end

module PartSet = Set.Make (PartNumber)

let get_parts_from_line line row =
  let make_part start finish =
    let value = Int.of_string (String.slice line start (finish + 1)) in
    PartNumber.{ row; col_start = start; col_end = finish; value }
  in
  let rec aux start finish idx chars acc =
    match start, finish, chars with
    | None, None, '0' .. '9' :: rest ->
      aux (Some idx) (Some idx) (idx + 1) rest acc
    | None, None, _ :: rest -> aux None None (idx + 1) rest acc
    | Some start, _, '0' .. '9' :: rest ->
      aux (Some start) (Some idx) (idx + 1) rest acc
    | Some start, Some finish, _ :: rest ->
      let part = make_part start finish in
      aux None None (idx + 1) rest (part :: acc)
    | Some start, _, [] ->
      let part = make_part start (String.length line - 1) in
      part :: acc
    | _, _, [] -> acc
    (*  Might have missed a case OMEGALUL *)
    | _ -> assert false
  in
  aux None None 0 (String.to_list line) []
;;

let acc_from_lines lines getter =
  List.foldi lines ~init:[] ~f:(fun idx acc line ->
    let symbols = getter line idx in
    symbols @ acc)
;;

let () =
  let lines = Advent.read_lines "./inputs/03-prod.txt" in
  let symbols = acc_from_lines lines get_symbols_from_line in
  let parts = acc_from_lines lines get_parts_from_line in
  let result =
    List.fold symbols ~init:PartSet.empty ~f:(fun acc symbol ->
      List.fold parts ~init:acc ~f:(fun set part ->
        match PartNumber.collides part symbol with
        | true -> PartSet.add part set
        | false -> set))
  in
  let result = PartSet.fold (fun part acc -> part.value + acc) result 0 in
  Fmt.pr "@. Final Result => %d@." result;
  ()
;;

let get_gears_from_line line row =
  let characters = String.to_list line in
  List.filter_mapi characters ~f:(fun col ch ->
    match ch with
    | '*' -> Some { row; col; ch }
    | _ -> None)
;;

let () =
  Fmt.pr "@.@.=========== PART 2 ================== @.@.";
  let lines = Advent.read_lines "./inputs/03-prod.txt" in
  let gears = acc_from_lines lines get_gears_from_line in
  let parts = acc_from_lines lines get_parts_from_line in
  let result =
    List.fold gears ~init:0 ~f:(fun acc symbol ->
      let matching_parts =
        List.fold parts ~init:PartSet.empty ~f:(fun set part ->
          match PartNumber.collides part symbol with
          | true -> PartSet.add part set
          | false -> set)
      in
      match PartSet.cardinal matching_parts with
      | 2 ->
        acc + PartSet.fold (fun part acc -> part.value * acc) matching_parts 1
      | _ -> acc)
  in
  Fmt.pr "@. Final Result => (75220503) %d (%b)@." result (75220503 = result);
  Fmt.pr "@.@.===================================== @.@.";
  ()
;;
