
(* The type of tokens. *)

type token = 
  | VAR of (string)
  | RPAREN
  | RBRAC
  | LPAREN
  | LBRAC
  | EOF
  | DOT
  | COMMA
  | BACKSLASH

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val parse: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (term)
