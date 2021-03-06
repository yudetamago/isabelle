(*  Title:      Pure/General/alist.ML
    Author:     Florian Haftmann, TU Muenchen

Association lists -- lists of (key, value) pairs.
*)

signature ALIST =
sig
  exception DUP
  val lookup: ('a * 'b -> bool) -> ('b * 'c) list -> 'a -> 'c option
  val defined: ('a * 'b -> bool) -> ('b * 'c) list -> 'a -> bool
  val update: ('a * 'a -> bool) -> ('a * 'b)
    -> ('a * 'b) list -> ('a * 'b) list
  val default: ('a * 'a -> bool) -> ('a * 'b)
    -> ('a * 'b) list -> ('a * 'b) list
  val delete: ('a * 'b -> bool) -> 'a
    -> ('b * 'c) list -> ('b * 'c) list
  val map_entry: ('a * 'b -> bool) -> 'a -> ('c -> 'c)
    -> ('b * 'c) list -> ('b * 'c) list
  val map_entry_yield: ('a * 'b -> bool) -> 'a -> ('c -> 'd * 'c)
    -> ('b * 'c) list -> 'd option * ('b * 'c) list
  val map_default: ('a * 'a -> bool) -> 'a * 'b -> ('b -> 'b)
    -> ('a * 'b) list -> ('a * 'b) list
  val join: ('a * 'a -> bool) -> ('a -> 'b * 'b -> 'b) (*exception DUP*)
    -> ('a * 'b) list * ('a * 'b) list -> ('a * 'b) list    (*exception DUP*)
  val merge: ('a * 'a -> bool) -> ('b * 'b -> bool)
    -> ('a * 'b) list * ('a * 'b) list -> ('a * 'b) list    (*exception DUP*)
  val make: ('a -> 'b) -> 'a list -> ('a * 'b) list
  val find: ('a * 'b -> bool) -> ('c * 'b) list -> 'a -> 'c list
  val coalesce: ('a * 'a -> bool) -> ('a * 'b) list -> ('a * 'b list) list
    (*coalesce ranges of equal neighbour keys*)
  val group: ('a * 'a -> bool) -> ('a * 'b) list -> ('a * 'b list) list
end;

structure AList: ALIST =
struct

fun find_index eq xs key =
  let
    fun find [] _ = ~1
      | find ((key', value)::xs) i =
          if eq (key, key')
          then i
          else find xs (i+1);
  in find xs 0 end;

fun map_index eq key f_none f_some xs =
  let
    val i = find_index eq xs key;
    fun mapp 0 (x::xs) = f_some x xs
      | mapp i (x::xs) = x :: mapp (i-1) xs;
  in (if i = ~1 then f_none else mapp i) xs end;

fun lookup _ [] _ = NONE
  | lookup eq ((key, value)::xs) key' =
      if eq (key', key) then SOME value
      else lookup eq xs key';

fun defined _ [] _ = false
  | defined eq ((key, value)::xs) key' =
      eq (key', key) orelse defined eq xs key';

fun update eq (x as (key, value)) =
  map_index eq key (cons x) (fn _ => cons x);

fun default eq (key, value) xs =
  if defined eq xs key then xs else (key, value) :: xs;

fun delete eq key =
  map_index eq key I (K I);

fun map_entry eq key f =
  map_index eq key I (fn (key, value) => cons (key, f value));

fun map_default eq (key, value) f =
  map_index eq key (cons (key, f value)) (fn (key, value) => cons (key, f value));

fun map_entry_yield eq key f xs =
  let
    val i = find_index eq xs key;
    fun mapp 0 ((x as (key, value))::xs) =
          let val (r, value') = f value
          in (SOME r, (key, value') :: xs) end
      | mapp i (x::xs) =
          let val (r, xs') = mapp (i-1) xs
          in (r, x::xs') end;
  in if i = ~1 then (NONE, xs) else mapp i xs end;

exception DUP;

fun join eq f (xs, ys) =
  let
    fun add (y as (key, value)) xs =
      (case lookup eq xs key of
        NONE => cons y xs
      | SOME value' => update eq (key, f key (value', value)) xs);
  in fold_rev add ys xs end;

fun merge eq_key eq_val =
  join eq_key (K (fn (yx as (_, x)) => if eq_val yx then x else raise DUP));

fun make keyfun =
  let fun keypair x = (x, keyfun x)
  in map keypair end;

fun find eq [] _ = []
  | find eq ((key, value) :: xs) value' =
      let
        val values = find eq xs value';
      in if eq (value', value) then key :: values else values end;

fun coalesce eq =
  let
    fun vals _ [] = ([], [])
      | vals x (lst as (y, b) :: ps) =
          if eq (x, y) then vals x ps |>> cons b
          else ([], lst);
    fun coal [] = []
      | coal ((x, a) :: ps) =
          let val (bs, qs) = vals x ps
          in (x, a :: bs) :: coal qs end;
  in coal end;

fun group eq xs =
  fold_rev (fn (k, v) => map_default eq (k, []) (cons v)) xs [];

end;
