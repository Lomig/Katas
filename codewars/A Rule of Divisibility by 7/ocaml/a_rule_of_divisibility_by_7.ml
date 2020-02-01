let seven : int -> int * int = fun m ->
  let rec algorithm = fun m i ->
    match m < 100 with
    | true -> m, i
    | false -> algorithm ((m / 10) - (2 * (m mod 10))) (i + 1)
  in
  algorithm m 0
;;
