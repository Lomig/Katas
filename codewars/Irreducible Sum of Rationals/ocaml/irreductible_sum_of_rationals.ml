(* ---------------------------------------------------------
-- Helpers                                                --
----------------------------------------------------------*)

let maxi : int -> int -> int = fun x y ->
  match x > y with
  | true -> x
  | false -> y
;;

let mini : int -> int -> int = fun x y ->
  match x < y with
  | true -> x
  | false -> y
;;

let rec gcdi : int -> int -> int = fun  u v ->
  let x = (maxi (abs u) (abs v))
  and y = (mini (abs u) (abs v)) in

  match y = 0 with
  | true ->  x
  | false -> (gcdi y (x mod y))
;;

let lcmu : int -> int -> int = fun m n -> (abs (m * n)) / (gcdi m n);;

(* ---------------------------------------------------------
-- Main Algorithm                                         --
----------------------------------------------------------*)

let sum_fracts : (int * int) list -> string option = fun xs ->

  (* Puts a fraction in its irreducible form *)
  let reduce_fraction = fun (a, b) ->
    let divisor = gcdi a b in
    ((a / divisor), (b / divisor))
  in

  (* Adds 2 fractions and then reduce them *)
  (* If one of the fraction is invalid, keeps the result invalid to be dealt with afterwards *)
  let add_fractions = fun (a, b) (c, d) ->
    match b, d with
    | 0, y -> (0, 0)
    | x, 0 -> (0, 0)
    | x, y ->
        let multiple = lcmu b d in
        let sum = (a * (multiple / b)) + (c * (multiple / d)) in
        reduce_fraction (sum, multiple)
  in

  (* If the list is empty, we treat it as if populated with invalid fractions *)
  let xs' = match xs with
    | [] -> [(1, 0)]
    | _ -> xs
  in

  (* Any invalid fraction list has None as its sum *)
  let result = (List.fold_left (fun init e -> add_fractions init e) (0, 1) xs') in
  match result with
  | (x, 0) -> None
  | (x, 1) -> Some (string_of_int x)
  | (x, y) -> Some ((string_of_int x) ^ " " ^ (string_of_int y))
;;
