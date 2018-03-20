open Core_bench.Std

let map f xs =
  let rec work = function
    | x :: xs' -> f x :: work xs'
    | [] -> []
  in work xs
;;

let foldl f z xs =
  let rec work z = function
    | x :: xs' -> work (f z x) xs'
    | [] -> z
  in work z xs
;;

let fused mapf foldf z xs =
  let rec work z = function
    | x :: xs' -> work (foldf z @@ mapf x) xs'
    | [] -> z
  in work z xs
;;

let () =
  Random.self_init ();
  let open Core_bench.Test in
  let double x = x * x in
  let arg = Array.(init 10000 (fun _ -> Random.int 10000) |> to_list) in
  Core.Command.run @@ Bench.make_command [
    create ~name: "map"     (fun () -> ignore @@ map double arg);
    create ~name: "foldl"   (fun () -> ignore @@ foldl (+) 0 arg);
    create ~name: "mapfold" (fun () -> ignore @@ foldl (+) 0 @@ map double arg);
    create ~name: "fused"   (fun () -> ignore @@ fused double (+) 0 arg)
  ]
