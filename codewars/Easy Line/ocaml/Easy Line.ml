(* ------------------------------------------------------
--- BIG INT Helpers                                   ---
-------------------------------------------------------*)

let (@+) x y = Big_int.add_big_int x y
let rec (@**.) x y = Big_int.power_big_int_positive_int x y
let i_to_I x = Big_int.big_int_of_int x

(* ------------------------------------------------------
--- Algorithm                                         ---
-------------------------------------------------------*)

let easyline : int -> string = fun n ->
  let rec pascal : int -> int -> Big_int.big_int list -> Big_int.big_int list = fun current_tier n acc ->

    let rec next_coeffs : Big_int.big_int list -> Big_int.big_int list = fun line ->
      match line with
      | [] -> []
      | [a] -> [a]
      | [a; b] -> [(a @+ b); b]
      | a::b::tail -> (a @+ b)::(next_coeffs (b::tail))
    in

    match current_tier = n with
    | true -> acc
    | false -> pascal (current_tier + 1) n ((i_to_I 1) :: (next_coeffs acc))
  in

  (pascal 0 n [i_to_I 1])
    |> List.fold_left (fun init x -> init @+ (x @**. 2)) (i_to_I 0)
    |> Big_int.string_of_big_int
