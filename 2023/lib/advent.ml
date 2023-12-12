open Core

let read_all file =
  Stdio.In_channel.with_file file ~f:(fun channel ->
    In_channel.input_all channel)
;;

let read_lines file =
  Stdio.In_channel.with_file file ~f:(fun channel ->
    let x = In_channel.input_all channel in
    String.split_lines x)
;;

let print_listof_strs ints =
  Format.printf
    "%a \n"
    (Format.pp_print_list
       ~pp_sep:(fun fmt () -> Format.fprintf fmt "; ")
       Format.pp_print_string)
    ints
;;

let directions = [ 0, 1; 1, 1; 1, 0; 1, -1; 0, -1; -1, -1; -1, 0; -1, 1 ]
let range start stop f = List.range start stop |> List.iter ~f

module A = struct
  include Angstrom

  let digit =
    let is_digit = function
      | '0' .. '9' -> true
      | _ -> false
    in
    take_while1 is_digit >>| Int.of_string <?> "digit: Parse one or more digits"
  ;;

  let space = take_while (fun ch -> Char.(ch = ' '))
  let whitespace = take_while Char.is_whitespace
  let newline = string "\n"
  let wstring str = whitespace *> string str <* whitespace
  let wmatch t = whitespace *> t <* whitespace
end

let range_seq start stop =
  let next i = if i > stop then None else Some (i, i + 1) in
  Seq.unfold next start
;;

let split_once ch str =
  let[@ocaml.warning "-8"] [ left; right ] =
    Stdlib.String.split_on_char ch str
  in
  left, right
;;

module CharMap = Map.Make (Char)

let char_count str =
  String.to_list str
  |> List.fold ~init:CharMap.empty ~f:(fun map ch ->
    Map.set map ~key:ch ~data:((Map.find map ch |> Option.value ~default:0) + 1))
;;
