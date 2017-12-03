{
    open Parser
    open Lexing
    exception Error of string
}

let space = [' ' '\t' '\n' '\r']
let digit = ['0'-'9']
let alpha = ['a'-'z' 'A'-'Z']
let alnum = digit | alpha

rule token = parse
    | '\\'          { BACKSLASH                            }
    | '.'           { DOT                                  }
    | ','           { COMMA                                }
    | '['           { LBRAC                                }
    | ']'           { RBRAC                                }
    | '('           { LPAREN                               }
    | ')'           { RPAREN                               }
    | xlower alnum* { VAR (lexeme lexbuf)                  }
    | space+        { token lexbuf                         }
    | eof           { EOF                                  }
    | _             { raise (Error (Printf.sprintf "At offset %d: unexpected character.\n" (Lexing.lexeme_start lexbuf)))
                                                           }
