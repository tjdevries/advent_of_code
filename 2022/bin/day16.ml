let input = Advent.read_lines "day16.txt"

let between s cs cf =
  let start = String.index s cs in
  let finish = String.index s cf in
  ( String.sub s (start + 1) (finish - start - 1),
    String.sub s (finish + 1) (String.length s - finish - 1) )
;;

module StringSet = Set.Make (String)
module StringMap = Map.Make (String)

module CostMap = Map.Make (struct
  type t = string * string

  let compare = Stdlib.compare
end)

module Valve = struct
  type t = {
    flow: int;
    name: string;
    connections: StringSet.t;
  }

  let name v = v.name
  let connections v = v.connections
  let flow v = v.flow

  let of_string line =
    let name = String.sub line 6 2 in
    let flow, line = between line '=' ';' in
    let flow = int_of_string flow in
    let connections =
      Str.replace_first (Str.regexp "tunnel[s]? lead[s]? to valve[s]?") "" line
      |> String.trim
      |> Str.split (Str.regexp ", ")
      |> StringSet.of_list
    in
    { name; flow; connections }
  ;;

  let to_string v =
    Format.sprintf "%s: %d (%d)" v.name v.flow (StringSet.cardinal v.connections)
  ;;
end

let get_costs useful valves =
  let find_valve name = List.find (fun v -> Valve.(v.name) = name) valves in
  let useful = find_valve "AA" :: useful in
  let bfs start dst =
    let rec inner cur dst visited depth =
      let name = Valve.name cur in
      if dst = name then
        depth
      else if StringSet.mem (Valve.name cur) visited then
        Int.max_int
      else if StringSet.mem dst (Valve.connections cur) then
        depth
      else
        StringSet.fold
          (fun s minimum ->
            min
              minimum
              (inner (find_valve s) dst (StringSet.add cur.name visited) (depth + 1)))
          (Valve.connections cur)
          Int.max_int
    in

    inner start dst StringSet.empty 1
  in

  Base.List.cartesian_product useful useful
  |> List.filter (fun (a, b) -> Valve.name a != Valve.name b)
  |> List.map (fun (a, b) -> (Valve.name a, Valve.name b), bfs a (Valve.name b))
  |> List.to_seq
  |> CostMap.of_seq
;;

let navigate valves costs time =
  let count = ref 0 in
  let cache = Hashtbl.create 1_000_000 in

  let get_val_or_key valves cur time =
    let name = Valve.(cur.name) in
    let keys =
      StringMap.to_seq valves
      |> Seq.map (fun (key, _) -> key)
      |> List.of_seq
      |> String.concat ""
    in
    let key = time, name, keys in
    let cached = Hashtbl.find_opt cache key in
    cached, key
  in

  let insert_flow key flow =
    Hashtbl.add cache key flow;
    flow
  in

  let rec nav_inner valves cur time acc =
    if time <= 0 then
      0
    else (
      let cached, key = get_val_or_key valves cur time in
      match cached with
      | None ->
        incr count;

        let time = time - 1 in
        let flow = time * Valve.flow cur in
        let name = Valve.name cur in
        let valves = StringMap.remove name valves in
        let children =
          StringMap.map
            (fun child ->
              nav_inner
                valves
                child
                (time - CostMap.find (name, Valve.name child) costs)
                0)
            valves
        in
        let max_child = StringMap.fold (fun _ v acc -> max v acc) children 0 in
        flow + max_child |> max acc |> insert_flow key
      | Some v -> v
    )
  in

  let n = nav_inner (StringMap.remove "AA" valves) (StringMap.find "AA" valves) time 0 in
  Format.sprintf "Called Count: %d" !count |> print_endline;

  n
;;

let part_1 input =
  let valves = List.fold_left (fun acc line -> Valve.of_string line :: acc) [] input in
  let useful_valves = List.filter (fun v -> Valve.(v.flow) != 0) valves in
  let costs = get_costs useful_valves valves in

  let find_valve name = List.find (fun v -> Valve.(v.name) = name) valves in
  let useful_valves = find_valve "AA" :: useful_valves in
  List.iter
    (fun v -> Format.sprintf "%s" (Valve.to_string v) |> print_endline)
    useful_valves;

  let valves =
    List.map (fun a -> Valve.name a, a) useful_valves |> List.to_seq |> StringMap.of_seq
  in

  navigate valves costs 31 |> Format.sprintf "Part 1: %d" |> print_endline
;;

let _ = if false then part_1 input

type mover = {
  dst: Valve.t;
  rem: int;
}

let navigate_2 valves costs time =
  let count = ref 0 in

  let next_mover valves (cur : mover) (child : Valve.t) =
    if cur.dst.name = child.name then
      Format.sprintf "Oh no, we failed with: %s %s" cur.dst.name child.name
      |> print_endline;

    let key = cur.dst.name, child.name in
    let cost = CostMap.find key costs in
    StringMap.remove child.name valves, { dst = child; rem = cost }
  in

  let get_max_child valves folder =
    StringMap.fold (fun _ child acc -> folder child |> max acc) valves 0
  in

  let rec maxflow remaining a b time =
    let time = time - 1 in
    let a = { a with rem = a.rem - 1 } in
    let b = { b with rem = b.rem - 1 } in

    (* if a.rem < 0 then assert false; *)
    (* if b.rem < 0 then assert false; *)
    if time <= 0 || StringMap.cardinal remaining = 0 then
      0
    else (
      incr count;

      let flow = 0 in
      let newa, flow =
        if a.rem <= 0 then
          true, flow + (time * a.dst.flow)
        else
          false, flow
      in
      let newb, flow =
        if b.rem <= 0 then
          true, flow + (time * b.dst.flow)
        else
          false, flow
      in

      flow
      +
      match newa, newb with
      | false, false -> maxflow remaining a b time
      | true, false ->
        get_max_child remaining (fun child ->
          let valves, a = next_mover remaining a child in
          maxflow valves a b time)
      | false, true ->
        get_max_child remaining (fun child ->
          let valves, b = next_mover remaining b child in
          maxflow valves a b time)
      | true, true ->
        let max_1 =
          StringMap.fold
            (fun _ child acc ->
              let remaining, a = next_mover remaining a child in
              let max_child =
                get_max_child remaining (fun child ->
                  let remaining, b = next_mover remaining b child in
                  maxflow remaining a b time)
              in
              max max_child acc)
            remaining
            0
        in
        let max_2 =
          StringMap.fold
            (fun _ child acc ->
              let remaining, b = next_mover remaining b child in
              let max_child =
                get_max_child remaining (fun child ->
                  let remaining, a = next_mover remaining a child in
                  maxflow remaining a b time)
              in
              max max_child acc)
            remaining
            0
        in
        max max_1 max_2
    )
  in

  let aa = StringMap.find "AA" valves in
  let aa = { dst = aa; rem = 0 } in
  let n = maxflow (StringMap.remove "AA" valves) aa aa time in
  Format.sprintf "Called Count: %d" !count |> print_endline;

  n
;;

let part_2 input =
  let valves = List.fold_left (fun acc line -> Valve.of_string line :: acc) [] input in
  let useful_valves = List.filter (fun v -> Valve.(v.flow) != 0) valves in
  let costs = get_costs useful_valves valves in

  let find_valve name = List.find (fun v -> Valve.(v.name) = name) valves in
  let useful_valves = find_valve "AA" :: useful_valves in
  List.iter
    (fun v -> Format.sprintf "%s" (Valve.to_string v) |> print_endline)
    useful_valves;

  let valves =
    List.map (fun a -> Valve.name a, a) useful_valves |> List.to_seq |> StringMap.of_seq
  in

  navigate_2 valves costs 27 |> Format.sprintf "Part 2 (want 1707): %d" |> print_endline
;;

let _ = part_2 input
