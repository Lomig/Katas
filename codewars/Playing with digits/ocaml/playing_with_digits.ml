let dig_pow : int -> int -> int = fun n p ->
  let rec decompose : int -> int list = fun n ->
    match n with
    | n when n < 10 -> [n]
    | _ -> (n mod 10) :: (decompose (n / 10))
  in

  let rec add_power : int list -> int -> int -> int -> int = fun x p index acc ->
    let (@*) u v = int_of_float((float_of_int u) ** (float_of_int v)) in

    match x with
    | [] -> acc
    | head::tail -> add_power tail p (index + 1) (acc + (head @* (p + index)))
  in

  let sum = add_power (List.rev (decompose n)) p 0 0 in

  match sum mod n with
  | 0 -> sum / n
  | _ -> -1
;;
