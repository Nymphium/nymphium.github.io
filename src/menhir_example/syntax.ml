type term =
  | Var of string
  | Lamb of string * term
  | App of term * term
  | List of term list
