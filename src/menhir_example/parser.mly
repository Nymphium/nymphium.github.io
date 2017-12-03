%{
open Syntax
%}

%token LBRAC RBRAC LPAREN RPAREN BACKSLASH DOT COMMA
%token <string> VAR
%token EOF

%start parse
%type <term> parse
%%

parse: | term EOF { $1 }
term:  | lamb { $1 }
       | VAR { Var $1 }
       | lst { $1 }
       | app { $1 }
       | LPAREN term RPAREN { $2 }
lamb:  | BACKSLASH VAR DOT term { Lamb($2, $4) }
app:   | term term { App($1, $2) }
lstcont:
       | { [] }
       | term { [$1] }
       | term COMMA lstcont { $1 :: $3 }
lst:   | LBRAC lstcont RBRAC { List $2 }
