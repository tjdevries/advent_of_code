let lines = Advent.read_lines "day7.txt"
let filter_value = 100_000
let total_size = 70000000
let required_size = 30000000

module LsLine = struct
  type t =
    | Directory of { name: string }
    | File of {
        name: string;
        size: int;
      }

  let is_dir = function
    | Directory _ -> true
    | _ -> false
  ;;

  let is_file = function
    | File _ -> true
    | _ -> false
  ;;

  let of_string = function
    | s when String.starts_with ~prefix:"dir" s ->
      Directory { name = String.sub s 4 (String.length s - 4) |> String.trim }
    | s ->
      let size, name = Advent.split_once ' ' s in
      let size = int_of_string size in
      File { name; size }
  ;;
end

module Folder = struct
  type t = {
    name: string;
    parent: t option;
    mutable remaining: int;
    mutable size: int;
  }

  let create name parent = { name; parent; remaining = 0; size = 0 }
  let parent folder = folder.parent

  let to_string folder =
    Format.sprintf "Folder(%s %d r=%d)" folder.name folder.size folder.remaining
  ;;

  let print_folders folders =
    List.iter (fun f -> Format.printf "%s | " (to_string f)) folders;
    print_newline ()
  ;;

  let rec get_home folder =
    match folder.parent with
    | None -> folder
    | Some f -> get_home f
  ;;

  let process_ls folder ls =
    folder.remaining <- List.filter LsLine.is_dir ls |> List.length;
    folder.size
      <- List.filter_map
           (fun line ->
             match line with
             | LsLine.File f -> Some f.size
             | _ -> None)
           ls
         |> List.fold_left (fun acc size -> acc + size) 0
  ;;

  let process_folder ~parent ~leaf =
    parent.remaining <- parent.remaining - 1;
    parent.size <- parent.size + leaf.size;
    parent
  ;;
end

let get_leaves input =
  (* Base.Option.apply *)
  let ( >>| ) = Base.Option.( >>| ) in

  let get_ls_lines lines =
    let rec helper lines acc =
      match lines with
      | [] -> lines, acc
      | hd :: _ when String.starts_with ~prefix:"$" hd -> lines, acc
      | hd :: tail -> helper tail (LsLine.of_string hd :: acc)
    in
    helper lines []
  in

  let do_ls _ lines folder leaves =
    let lines, ls = get_ls_lines lines in
    Folder.process_ls folder ls;
    let is_leaf = List.for_all LsLine.is_file ls in
    ( lines,
      folder,
      if is_leaf then
        folder :: leaves
      else
        leaves )
  in
  let do_cd_home _ lines folder leaves = lines, Folder.get_home folder, leaves in
  let do_cd_up _ lines folder leaves =
    lines, Folder.parent folder |> Option.get, leaves
  in
  let do_cd cmd lines folder leaves =
    lines, Folder.create (String.sub cmd 4 (String.length cmd - 4)) (Some folder), leaves
  in

  let get_all_leaves lines =
    let rec helper lines folder leaves =
      let get_combinator hd =
        match hd with
        | hd when hd = "$ cd /" -> do_cd_home
        | hd when hd = "$ cd .." -> do_cd_up
        | hd when String.starts_with ~prefix:"$ cd" hd -> do_cd
        | hd when String.starts_with ~prefix:"$ ls" hd -> do_ls
        | _ -> assert false
      in
      let execute combinator = combinator (List.hd lines) (List.tl lines) folder leaves in
      match Base.List.hd lines >>| get_combinator >>| execute with
      | None -> leaves
      | Some (lines, folder, leaves) -> helper lines folder leaves
    in
    helper lines (Folder.create "/" None) []
  in
  get_all_leaves input
;;

let process_leaves leaves init filter accumulator =
  let rec helper leaves acc =
    match leaves with
    | [] -> acc
    | leaf :: leaves ->
      let leaves =
        match Folder.parent leaf with
        | None -> leaves
        | Some parent ->
          let parent = Folder.process_folder ~parent ~leaf in
          if parent.remaining == 0 && filter acc parent then
            parent :: leaves
          else
            leaves
      in
      let acc = accumulator acc leaf in
      helper leaves acc
  in

  helper leaves init
;;

let part_1 leaves =
  if false then Folder.print_folders leaves;

  process_leaves
    leaves
    0
    (fun _ parent -> parent.size <= filter_value)
    (fun acc leaf ->
      if leaf.size <= filter_value then
        acc + leaf.size
      else
        acc)
;;

let currently_used leaves =
  process_leaves leaves 0 (fun _ _ -> true) (fun _ leaf -> leaf.size)
;;

let part_2 leaves root_size =
  let target = root_size - (total_size - required_size) in
  Format.printf
    "Total size: %d\nUnusued Size: %d\nTarget: %d\n"
    total_size
    required_size
    target;

  process_leaves
    leaves
    root_size
    (fun acc parent -> parent.size <= acc)
    (fun acc leaf ->
      if leaf.size >= target then
        min acc leaf.size
      else
        acc)
;;

(* Part 1 *)
let leaves = get_leaves lines
let processed = part_1 leaves
let _ = Format.printf "Part 1: %d\n" processed
let _ = print_endline ""

(* Part 2 *)
let root_size = get_leaves lines |> currently_used
let leaves = get_leaves lines
let processed = part_2 leaves root_size
let _ = Format.printf "Part 2: %d\n" processed
let _ = print_endline ""
