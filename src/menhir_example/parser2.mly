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
       | LPAREN t = term RPAREN { t }
lamb:  | BACKSLASH x = VAR DOT t = term { Lamb(x, t) }
app:   | term term { App($1, $2) }
lst:   | LBRAC lst = separated_list(COMMA, term) RBRAC { List lst }
