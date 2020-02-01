let rec number_to_letters = fun n list ->
  match n, list with
  | 0, head::tail -> head
  | _, head::tail -> number_to_letters (n - 1) tail
  | _, [] -> ""
;;

let numbers = ["zero"; "one"; "two"; "three"; "four"; "five";
               "six"; "seven"; "eight"; "nine"; "ten";
               "eleven"; "twelve"; "thirteen"; "fourteen"; "fifteen";
               "sixteen"; "seventeen"; "eighteen"; "nineteen"; "twenty"]
;;

let wallPaper (l: float) (w: float) (h: float) =
  let number_panels = 2. *. (w +. l) /. 0.52 in
  let number_of_rolls = int_of_float @@ ceil (h /. 10. *. (number_panels) *. 1.15) in

  number_to_letters number_of_rolls numbers
;;
