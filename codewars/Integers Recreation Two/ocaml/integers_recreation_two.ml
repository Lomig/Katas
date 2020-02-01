let prod2Sum (a: int) (b: int) (c: int) (d: int): int array array =

  let solution1 = List.sort compare [(abs ((a * c) + (b * d))); (abs ((a * d) - (b * c)))] in
  let solution2 = List.sort compare [(abs ((a * c) - (b * d))); (abs ((a * d) + (b * c)))] in

  match solution1, solution2 with
  | [x; _], [x'; _] when x = x' -> [| solution1 |> Array.of_list |]
  | _, _ -> [(Array.of_list solution1); (Array.of_list solution2)] |> List.sort compare |> Array.of_list
;;
