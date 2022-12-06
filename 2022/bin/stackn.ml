(* Empty thing *)
(* Node, next: Null *)
(* Node, next: Node *)
module StackN = struct
  type t =
    | Empty
    | Node of {
        mutable next: t;
        value: char;
      }

  let create () = Empty
  let push next value = Node { next; value }

  let pop stack =
    match stack with
    | Empty -> assert false
    | Node n -> n.value, n.next
  ;;

  let rec tail stackn =
    match stackn with
    | Empty -> assert false
    | Node n ->
      (match n.next with
       | Empty -> Node n
       | n -> tail n)
  ;;

  let push_stackn dst src =
    match tail src with
    | Empty -> assert false
    | Node n ->
      n.next <- dst;
      src
  ;;

  let rec nth n stackn =
    match n with
    | 0 -> stackn
    | n ->
      (match stackn with
       | Empty -> assert false
       | node -> nth (n - 1) node)
  ;;

  (* let pop_stackn src amount = *)
end

let stack = StackN.create ()
let stack = StackN.push stack 'A'
let stack = StackN.push stack 'B'
let stack = StackN.push stack 'C'

let _ =
  let value, _ = StackN.pop stack in
  print_char value;
  print_endline ""
;;
