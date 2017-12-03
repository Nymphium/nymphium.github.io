
module MenhirBasics = struct
  
  exception Error
  
  type token = 
    | VAR of (
# 6 "parser2.mly"
       (string)
# 11 "parser2.ml"
  )
    | RPAREN
    | RBRAC
    | LPAREN
    | LBRAC
    | EOF
    | DOT
    | COMMA
    | BACKSLASH
  
end

include MenhirBasics

let _eRR =
  MenhirBasics.Error

type _menhir_env = {
  _menhir_lexer: Lexing.lexbuf -> token;
  _menhir_lexbuf: Lexing.lexbuf;
  _menhir_token: token;
  mutable _menhir_error: bool
}

and _menhir_state = 
  | MenhirState20
  | MenhirState18
  | MenhirState13
  | MenhirState12
  | MenhirState8
  | MenhirState7
  | MenhirState6
  | MenhirState3
  | MenhirState2
  | MenhirState0

# 1 "parser2.mly"
  
open Syntax

# 52 "parser2.ml"

let rec _menhir_goto_separated_nonempty_list_COMMA_term_ : _menhir_env -> 'ttv_tail -> _menhir_state -> 'tv_separated_nonempty_list_COMMA_term_ -> 'ttv_return =
  fun _menhir_env _menhir_stack _menhir_s _v ->
    match _menhir_s with
    | MenhirState13 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : ('freshtv95 * _menhir_state * 'tv_term) * _menhir_state) = Obj.magic _menhir_stack in
        let (_menhir_s : _menhir_state) = _menhir_s in
        let (_v : 'tv_separated_nonempty_list_COMMA_term_) = _v in
        ((let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : ('freshtv93 * _menhir_state * 'tv_term) * _menhir_state) = Obj.magic _menhir_stack in
        let (_ : _menhir_state) = _menhir_s in
        let ((xs : 'tv_separated_nonempty_list_COMMA_term_) : 'tv_separated_nonempty_list_COMMA_term_) = _v in
        ((let ((_menhir_stack, _menhir_s, (x : 'tv_term)), _) = _menhir_stack in
        let _2 = () in
        let _v : 'tv_separated_nonempty_list_COMMA_term_ = 
# 217 "/home/nymphium/.opam/system/lib/menhir/standard.mly"
    ( x :: xs )
# 71 "parser2.ml"
         in
        _menhir_goto_separated_nonempty_list_COMMA_term_ _menhir_env _menhir_stack _menhir_s _v) : 'freshtv94)) : 'freshtv96)
    | MenhirState3 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv99) = Obj.magic _menhir_stack in
        let (_menhir_s : _menhir_state) = _menhir_s in
        let (_v : 'tv_separated_nonempty_list_COMMA_term_) = _v in
        ((let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv97) = Obj.magic _menhir_stack in
        let (_menhir_s : _menhir_state) = _menhir_s in
        let ((x : 'tv_separated_nonempty_list_COMMA_term_) : 'tv_separated_nonempty_list_COMMA_term_) = _v in
        ((let _v : 'tv_loption_separated_nonempty_list_COMMA_term__ = 
# 130 "/home/nymphium/.opam/system/lib/menhir/standard.mly"
    ( x )
# 86 "parser2.ml"
         in
        _menhir_goto_loption_separated_nonempty_list_COMMA_term__ _menhir_env _menhir_stack _menhir_s _v) : 'freshtv98)) : 'freshtv100)
    | _ ->
        let (() : unit) = () in
        ((Printf.fprintf Pervasives.stderr "Internal failure -- please contact the parser generator's developers.\n%!";
        assert false) : 'freshtv101)

and _menhir_goto_term : _menhir_env -> 'ttv_tail -> _menhir_state -> 'tv_term -> 'ttv_return =
  fun _menhir_env _menhir_stack _menhir_s _v ->
    let _menhir_stack = (_menhir_stack, _menhir_s, _v) in
    match _menhir_s with
    | MenhirState6 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : ((('freshtv57 * _menhir_state) * (
# 6 "parser2.mly"
       (string)
# 103 "parser2.ml"
        ))) * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
        ((assert (not _menhir_env._menhir_error);
        let _tok = _menhir_env._menhir_token in
        match _tok with
        | BACKSLASH ->
            _menhir_run4 _menhir_env (Obj.magic _menhir_stack) MenhirState7
        | LBRAC ->
            _menhir_run3 _menhir_env (Obj.magic _menhir_stack) MenhirState7
        | LPAREN ->
            _menhir_run2 _menhir_env (Obj.magic _menhir_stack) MenhirState7
        | VAR _v ->
            _menhir_run1 _menhir_env (Obj.magic _menhir_stack) MenhirState7 _v
        | COMMA | EOF | RBRAC | RPAREN ->
            let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : ((('freshtv55 * _menhir_state) * (
# 6 "parser2.mly"
       (string)
# 121 "parser2.ml"
            ))) * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
            ((let (((_menhir_stack, _menhir_s), (x : (
# 6 "parser2.mly"
       (string)
# 126 "parser2.ml"
            ))), _, (t : 'tv_term)) = _menhir_stack in
            let _3 = () in
            let _1 = () in
            let _v : 'tv_lamb = 
# 19 "parser2.mly"
                                        ( Lamb(x, t) )
# 133 "parser2.ml"
             in
            let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : 'freshtv53) = _menhir_stack in
            let (_menhir_s : _menhir_state) = _menhir_s in
            let (_v : 'tv_lamb) = _v in
            ((let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : 'freshtv51) = Obj.magic _menhir_stack in
            let (_menhir_s : _menhir_state) = _menhir_s in
            let (_v : 'tv_lamb) = _v in
            ((let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : 'freshtv49) = Obj.magic _menhir_stack in
            let (_menhir_s : _menhir_state) = _menhir_s in
            let ((_1 : 'tv_lamb) : 'tv_lamb) = _v in
            ((let _v : 'tv_term = 
# 14 "parser2.mly"
              ( _1 )
# 150 "parser2.ml"
             in
            _menhir_goto_term _menhir_env _menhir_stack _menhir_s _v) : 'freshtv50)) : 'freshtv52)) : 'freshtv54)) : 'freshtv56)
        | _ ->
            assert (not _menhir_env._menhir_error);
            _menhir_env._menhir_error <- true;
            _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) MenhirState7) : 'freshtv58)
    | MenhirState20 | MenhirState18 | MenhirState12 | MenhirState8 | MenhirState7 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : ('freshtv67 * _menhir_state * 'tv_term) * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
        ((assert (not _menhir_env._menhir_error);
        let _tok = _menhir_env._menhir_token in
        match _tok with
        | BACKSLASH ->
            _menhir_run4 _menhir_env (Obj.magic _menhir_stack) MenhirState8
        | LBRAC ->
            _menhir_run3 _menhir_env (Obj.magic _menhir_stack) MenhirState8
        | LPAREN ->
            _menhir_run2 _menhir_env (Obj.magic _menhir_stack) MenhirState8
        | VAR _v ->
            _menhir_run1 _menhir_env (Obj.magic _menhir_stack) MenhirState8 _v
        | COMMA | EOF | RBRAC | RPAREN ->
            let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : ('freshtv65 * _menhir_state * 'tv_term) * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
            ((let ((_menhir_stack, _menhir_s, (_1 : 'tv_term)), _, (_2 : 'tv_term)) = _menhir_stack in
            let _v : 'tv_app = 
# 20 "parser2.mly"
                   ( App(_1, _2) )
# 178 "parser2.ml"
             in
            let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : 'freshtv63) = _menhir_stack in
            let (_menhir_s : _menhir_state) = _menhir_s in
            let (_v : 'tv_app) = _v in
            ((let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : 'freshtv61) = Obj.magic _menhir_stack in
            let (_menhir_s : _menhir_state) = _menhir_s in
            let (_v : 'tv_app) = _v in
            ((let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : 'freshtv59) = Obj.magic _menhir_stack in
            let (_menhir_s : _menhir_state) = _menhir_s in
            let ((_1 : 'tv_app) : 'tv_app) = _v in
            ((let _v : 'tv_term = 
# 17 "parser2.mly"
             ( _1 )
# 195 "parser2.ml"
             in
            _menhir_goto_term _menhir_env _menhir_stack _menhir_s _v) : 'freshtv60)) : 'freshtv62)) : 'freshtv64)) : 'freshtv66)
        | _ ->
            assert (not _menhir_env._menhir_error);
            _menhir_env._menhir_error <- true;
            _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) MenhirState8) : 'freshtv68)
    | MenhirState13 | MenhirState3 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv73 * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
        ((assert (not _menhir_env._menhir_error);
        let _tok = _menhir_env._menhir_token in
        match _tok with
        | BACKSLASH ->
            _menhir_run4 _menhir_env (Obj.magic _menhir_stack) MenhirState12
        | COMMA ->
            let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : 'freshtv69 * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
            let (_menhir_s : _menhir_state) = MenhirState12 in
            ((let _menhir_stack = (_menhir_stack, _menhir_s) in
            let _menhir_env = _menhir_discard _menhir_env in
            let _tok = _menhir_env._menhir_token in
            match _tok with
            | BACKSLASH ->
                _menhir_run4 _menhir_env (Obj.magic _menhir_stack) MenhirState13
            | LBRAC ->
                _menhir_run3 _menhir_env (Obj.magic _menhir_stack) MenhirState13
            | LPAREN ->
                _menhir_run2 _menhir_env (Obj.magic _menhir_stack) MenhirState13
            | VAR _v ->
                _menhir_run1 _menhir_env (Obj.magic _menhir_stack) MenhirState13 _v
            | _ ->
                assert (not _menhir_env._menhir_error);
                _menhir_env._menhir_error <- true;
                _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) MenhirState13) : 'freshtv70)
        | LBRAC ->
            _menhir_run3 _menhir_env (Obj.magic _menhir_stack) MenhirState12
        | LPAREN ->
            _menhir_run2 _menhir_env (Obj.magic _menhir_stack) MenhirState12
        | VAR _v ->
            _menhir_run1 _menhir_env (Obj.magic _menhir_stack) MenhirState12 _v
        | RBRAC ->
            let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : 'freshtv71 * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
            ((let (_menhir_stack, _menhir_s, (x : 'tv_term)) = _menhir_stack in
            let _v : 'tv_separated_nonempty_list_COMMA_term_ = 
# 215 "/home/nymphium/.opam/system/lib/menhir/standard.mly"
    ( [ x ] )
# 243 "parser2.ml"
             in
            _menhir_goto_separated_nonempty_list_COMMA_term_ _menhir_env _menhir_stack _menhir_s _v) : 'freshtv72)
        | _ ->
            assert (not _menhir_env._menhir_error);
            _menhir_env._menhir_error <- true;
            _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) MenhirState12) : 'freshtv74)
    | MenhirState2 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : ('freshtv79 * _menhir_state) * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
        ((assert (not _menhir_env._menhir_error);
        let _tok = _menhir_env._menhir_token in
        match _tok with
        | BACKSLASH ->
            _menhir_run4 _menhir_env (Obj.magic _menhir_stack) MenhirState18
        | LBRAC ->
            _menhir_run3 _menhir_env (Obj.magic _menhir_stack) MenhirState18
        | LPAREN ->
            _menhir_run2 _menhir_env (Obj.magic _menhir_stack) MenhirState18
        | RPAREN ->
            let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : ('freshtv77 * _menhir_state) * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
            let (_menhir_s : _menhir_state) = MenhirState18 in
            ((let _menhir_env = _menhir_discard _menhir_env in
            let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : ('freshtv75 * _menhir_state) * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
            let (_ : _menhir_state) = _menhir_s in
            ((let ((_menhir_stack, _menhir_s), _, (t : 'tv_term)) = _menhir_stack in
            let _3 = () in
            let _1 = () in
            let _v : 'tv_term = 
# 18 "parser2.mly"
                                ( t )
# 276 "parser2.ml"
             in
            _menhir_goto_term _menhir_env _menhir_stack _menhir_s _v) : 'freshtv76)) : 'freshtv78)
        | VAR _v ->
            _menhir_run1 _menhir_env (Obj.magic _menhir_stack) MenhirState18 _v
        | _ ->
            assert (not _menhir_env._menhir_error);
            _menhir_env._menhir_error <- true;
            _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) MenhirState18) : 'freshtv80)
    | MenhirState0 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv91 * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
        ((assert (not _menhir_env._menhir_error);
        let _tok = _menhir_env._menhir_token in
        match _tok with
        | BACKSLASH ->
            _menhir_run4 _menhir_env (Obj.magic _menhir_stack) MenhirState20
        | EOF ->
            let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : 'freshtv89 * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
            let (_menhir_s : _menhir_state) = MenhirState20 in
            ((let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : 'freshtv87 * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
            let (_ : _menhir_state) = _menhir_s in
            ((let (_menhir_stack, _menhir_s, (_1 : 'tv_term)) = _menhir_stack in
            let _2 = () in
            let _v : (
# 10 "parser2.mly"
      (term)
# 305 "parser2.ml"
            ) = 
# 13 "parser2.mly"
                  ( _1 )
# 309 "parser2.ml"
             in
            let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : 'freshtv85) = _menhir_stack in
            let (_menhir_s : _menhir_state) = _menhir_s in
            let (_v : (
# 10 "parser2.mly"
      (term)
# 317 "parser2.ml"
            )) = _v in
            ((let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : 'freshtv83) = Obj.magic _menhir_stack in
            let (_menhir_s : _menhir_state) = _menhir_s in
            let (_v : (
# 10 "parser2.mly"
      (term)
# 325 "parser2.ml"
            )) = _v in
            ((let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : 'freshtv81) = Obj.magic _menhir_stack in
            let (_menhir_s : _menhir_state) = _menhir_s in
            let ((_1 : (
# 10 "parser2.mly"
      (term)
# 333 "parser2.ml"
            )) : (
# 10 "parser2.mly"
      (term)
# 337 "parser2.ml"
            )) = _v in
            (Obj.magic _1 : 'freshtv82)) : 'freshtv84)) : 'freshtv86)) : 'freshtv88)) : 'freshtv90)
        | LBRAC ->
            _menhir_run3 _menhir_env (Obj.magic _menhir_stack) MenhirState20
        | LPAREN ->
            _menhir_run2 _menhir_env (Obj.magic _menhir_stack) MenhirState20
        | VAR _v ->
            _menhir_run1 _menhir_env (Obj.magic _menhir_stack) MenhirState20 _v
        | _ ->
            assert (not _menhir_env._menhir_error);
            _menhir_env._menhir_error <- true;
            _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) MenhirState20) : 'freshtv92)

and _menhir_goto_loption_separated_nonempty_list_COMMA_term__ : _menhir_env -> 'ttv_tail -> _menhir_state -> 'tv_loption_separated_nonempty_list_COMMA_term__ -> 'ttv_return =
  fun _menhir_env _menhir_stack _menhir_s _v ->
    let _menhir_stack = (_menhir_stack, _menhir_s, _v) in
    let (_menhir_env : _menhir_env) = _menhir_env in
    let (_menhir_stack : ('freshtv47 * _menhir_state) * _menhir_state * 'tv_loption_separated_nonempty_list_COMMA_term__) = Obj.magic _menhir_stack in
    ((assert (not _menhir_env._menhir_error);
    let _tok = _menhir_env._menhir_token in
    match _tok with
    | RBRAC ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : ('freshtv43 * _menhir_state) * _menhir_state * 'tv_loption_separated_nonempty_list_COMMA_term__) = Obj.magic _menhir_stack in
        ((let _menhir_env = _menhir_discard _menhir_env in
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : ('freshtv41 * _menhir_state) * _menhir_state * 'tv_loption_separated_nonempty_list_COMMA_term__) = Obj.magic _menhir_stack in
        ((let ((_menhir_stack, _menhir_s), _, (xs0 : 'tv_loption_separated_nonempty_list_COMMA_term__)) = _menhir_stack in
        let _3 = () in
        let _1 = () in
        let _v : 'tv_lst = let lst =
          let xs = xs0 in
          
# 206 "/home/nymphium/.opam/system/lib/menhir/standard.mly"
    ( xs )
# 373 "parser2.ml"
          
        in
        
# 21 "parser2.mly"
                                                       ( List lst )
# 379 "parser2.ml"
         in
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv39) = _menhir_stack in
        let (_menhir_s : _menhir_state) = _menhir_s in
        let (_v : 'tv_lst) = _v in
        ((let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv37) = Obj.magic _menhir_stack in
        let (_menhir_s : _menhir_state) = _menhir_s in
        let (_v : 'tv_lst) = _v in
        ((let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv35) = Obj.magic _menhir_stack in
        let (_menhir_s : _menhir_state) = _menhir_s in
        let ((_1 : 'tv_lst) : 'tv_lst) = _v in
        ((let _v : 'tv_term = 
# 16 "parser2.mly"
             ( _1 )
# 396 "parser2.ml"
         in
        _menhir_goto_term _menhir_env _menhir_stack _menhir_s _v) : 'freshtv36)) : 'freshtv38)) : 'freshtv40)) : 'freshtv42)) : 'freshtv44)
    | _ ->
        assert (not _menhir_env._menhir_error);
        _menhir_env._menhir_error <- true;
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : ('freshtv45 * _menhir_state) * _menhir_state * 'tv_loption_separated_nonempty_list_COMMA_term__) = Obj.magic _menhir_stack in
        ((let (_menhir_stack, _menhir_s, _) = _menhir_stack in
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) _menhir_s) : 'freshtv46)) : 'freshtv48)

and _menhir_errorcase : _menhir_env -> 'ttv_tail -> _menhir_state -> 'ttv_return =
  fun _menhir_env _menhir_stack _menhir_s ->
    match _menhir_s with
    | MenhirState20 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv15 * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
        ((let (_menhir_stack, _menhir_s, _) = _menhir_stack in
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) _menhir_s) : 'freshtv16)
    | MenhirState18 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : ('freshtv17 * _menhir_state) * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
        ((let (_menhir_stack, _menhir_s, _) = _menhir_stack in
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) _menhir_s) : 'freshtv18)
    | MenhirState13 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : ('freshtv19 * _menhir_state * 'tv_term) * _menhir_state) = Obj.magic _menhir_stack in
        ((let (_menhir_stack, _menhir_s) = _menhir_stack in
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) _menhir_s) : 'freshtv20)
    | MenhirState12 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv21 * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
        ((let (_menhir_stack, _menhir_s, _) = _menhir_stack in
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) _menhir_s) : 'freshtv22)
    | MenhirState8 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : ('freshtv23 * _menhir_state * 'tv_term) * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
        ((let (_menhir_stack, _menhir_s, _) = _menhir_stack in
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) _menhir_s) : 'freshtv24)
    | MenhirState7 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : ((('freshtv25 * _menhir_state) * (
# 6 "parser2.mly"
       (string)
# 440 "parser2.ml"
        ))) * _menhir_state * 'tv_term) = Obj.magic _menhir_stack in
        ((let (_menhir_stack, _menhir_s, _) = _menhir_stack in
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) _menhir_s) : 'freshtv26)
    | MenhirState6 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : (('freshtv27 * _menhir_state) * (
# 6 "parser2.mly"
       (string)
# 449 "parser2.ml"
        ))) = Obj.magic _menhir_stack in
        ((let ((_menhir_stack, _menhir_s), _) = _menhir_stack in
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) _menhir_s) : 'freshtv28)
    | MenhirState3 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv29 * _menhir_state) = Obj.magic _menhir_stack in
        ((let (_menhir_stack, _menhir_s) = _menhir_stack in
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) _menhir_s) : 'freshtv30)
    | MenhirState2 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv31 * _menhir_state) = Obj.magic _menhir_stack in
        ((let (_menhir_stack, _menhir_s) = _menhir_stack in
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) _menhir_s) : 'freshtv32)
    | MenhirState0 ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv33) = Obj.magic _menhir_stack in
        (raise _eRR : 'freshtv34)

and _menhir_run1 : _menhir_env -> 'ttv_tail -> _menhir_state -> (
# 6 "parser2.mly"
       (string)
# 471 "parser2.ml"
) -> 'ttv_return =
  fun _menhir_env _menhir_stack _menhir_s _v ->
    let _menhir_env = _menhir_discard _menhir_env in
    let (_menhir_env : _menhir_env) = _menhir_env in
    let (_menhir_stack : 'freshtv13) = Obj.magic _menhir_stack in
    let (_menhir_s : _menhir_state) = _menhir_s in
    let ((_1 : (
# 6 "parser2.mly"
       (string)
# 481 "parser2.ml"
    )) : (
# 6 "parser2.mly"
       (string)
# 485 "parser2.ml"
    )) = _v in
    ((let _v : 'tv_term = 
# 15 "parser2.mly"
             ( Var _1 )
# 490 "parser2.ml"
     in
    _menhir_goto_term _menhir_env _menhir_stack _menhir_s _v) : 'freshtv14)

and _menhir_run2 : _menhir_env -> 'ttv_tail -> _menhir_state -> 'ttv_return =
  fun _menhir_env _menhir_stack _menhir_s ->
    let _menhir_stack = (_menhir_stack, _menhir_s) in
    let _menhir_env = _menhir_discard _menhir_env in
    let _tok = _menhir_env._menhir_token in
    match _tok with
    | BACKSLASH ->
        _menhir_run4 _menhir_env (Obj.magic _menhir_stack) MenhirState2
    | LBRAC ->
        _menhir_run3 _menhir_env (Obj.magic _menhir_stack) MenhirState2
    | LPAREN ->
        _menhir_run2 _menhir_env (Obj.magic _menhir_stack) MenhirState2
    | VAR _v ->
        _menhir_run1 _menhir_env (Obj.magic _menhir_stack) MenhirState2 _v
    | _ ->
        assert (not _menhir_env._menhir_error);
        _menhir_env._menhir_error <- true;
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) MenhirState2

and _menhir_run3 : _menhir_env -> 'ttv_tail -> _menhir_state -> 'ttv_return =
  fun _menhir_env _menhir_stack _menhir_s ->
    let _menhir_stack = (_menhir_stack, _menhir_s) in
    let _menhir_env = _menhir_discard _menhir_env in
    let _tok = _menhir_env._menhir_token in
    match _tok with
    | BACKSLASH ->
        _menhir_run4 _menhir_env (Obj.magic _menhir_stack) MenhirState3
    | LBRAC ->
        _menhir_run3 _menhir_env (Obj.magic _menhir_stack) MenhirState3
    | LPAREN ->
        _menhir_run2 _menhir_env (Obj.magic _menhir_stack) MenhirState3
    | VAR _v ->
        _menhir_run1 _menhir_env (Obj.magic _menhir_stack) MenhirState3 _v
    | RBRAC ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv11) = Obj.magic _menhir_stack in
        let (_menhir_s : _menhir_state) = MenhirState3 in
        ((let _v : 'tv_loption_separated_nonempty_list_COMMA_term__ = 
# 128 "/home/nymphium/.opam/system/lib/menhir/standard.mly"
    ( [] )
# 534 "parser2.ml"
         in
        _menhir_goto_loption_separated_nonempty_list_COMMA_term__ _menhir_env _menhir_stack _menhir_s _v) : 'freshtv12)
    | _ ->
        assert (not _menhir_env._menhir_error);
        _menhir_env._menhir_error <- true;
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) MenhirState3

and _menhir_run4 : _menhir_env -> 'ttv_tail -> _menhir_state -> 'ttv_return =
  fun _menhir_env _menhir_stack _menhir_s ->
    let _menhir_stack = (_menhir_stack, _menhir_s) in
    let _menhir_env = _menhir_discard _menhir_env in
    let _tok = _menhir_env._menhir_token in
    match _tok with
    | VAR _v ->
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv7 * _menhir_state) = Obj.magic _menhir_stack in
        let (_v : (
# 6 "parser2.mly"
       (string)
# 554 "parser2.ml"
        )) = _v in
        ((let _menhir_stack = (_menhir_stack, _v) in
        let _menhir_env = _menhir_discard _menhir_env in
        let _tok = _menhir_env._menhir_token in
        match _tok with
        | DOT ->
            let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : ('freshtv3 * _menhir_state) * (
# 6 "parser2.mly"
       (string)
# 565 "parser2.ml"
            )) = Obj.magic _menhir_stack in
            ((let _menhir_env = _menhir_discard _menhir_env in
            let _tok = _menhir_env._menhir_token in
            match _tok with
            | BACKSLASH ->
                _menhir_run4 _menhir_env (Obj.magic _menhir_stack) MenhirState6
            | LBRAC ->
                _menhir_run3 _menhir_env (Obj.magic _menhir_stack) MenhirState6
            | LPAREN ->
                _menhir_run2 _menhir_env (Obj.magic _menhir_stack) MenhirState6
            | VAR _v ->
                _menhir_run1 _menhir_env (Obj.magic _menhir_stack) MenhirState6 _v
            | _ ->
                assert (not _menhir_env._menhir_error);
                _menhir_env._menhir_error <- true;
                _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) MenhirState6) : 'freshtv4)
        | _ ->
            assert (not _menhir_env._menhir_error);
            _menhir_env._menhir_error <- true;
            let (_menhir_env : _menhir_env) = _menhir_env in
            let (_menhir_stack : ('freshtv5 * _menhir_state) * (
# 6 "parser2.mly"
       (string)
# 589 "parser2.ml"
            )) = Obj.magic _menhir_stack in
            ((let ((_menhir_stack, _menhir_s), _) = _menhir_stack in
            _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) _menhir_s) : 'freshtv6)) : 'freshtv8)
    | _ ->
        assert (not _menhir_env._menhir_error);
        _menhir_env._menhir_error <- true;
        let (_menhir_env : _menhir_env) = _menhir_env in
        let (_menhir_stack : 'freshtv9 * _menhir_state) = Obj.magic _menhir_stack in
        ((let (_menhir_stack, _menhir_s) = _menhir_stack in
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) _menhir_s) : 'freshtv10)

and _menhir_discard : _menhir_env -> _menhir_env =
  fun _menhir_env ->
    let lexer = _menhir_env._menhir_lexer in
    let lexbuf = _menhir_env._menhir_lexbuf in
    let _tok = lexer lexbuf in
    {
      _menhir_lexer = lexer;
      _menhir_lexbuf = lexbuf;
      _menhir_token = _tok;
      _menhir_error = false;
    }

and parse : (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (
# 10 "parser2.mly"
      (term)
# 616 "parser2.ml"
) =
  fun lexer lexbuf ->
    let _menhir_env =
      let (lexer : Lexing.lexbuf -> token) = lexer in
      let (lexbuf : Lexing.lexbuf) = lexbuf in
      ((let _tok = Obj.magic () in
      {
        _menhir_lexer = lexer;
        _menhir_lexbuf = lexbuf;
        _menhir_token = _tok;
        _menhir_error = false;
      }) : _menhir_env)
    in
    Obj.magic (let (_menhir_env : _menhir_env) = _menhir_env in
    let (_menhir_stack : 'freshtv1) = ((), _menhir_env._menhir_lexbuf.Lexing.lex_curr_p) in
    ((let _menhir_env = _menhir_discard _menhir_env in
    let _tok = _menhir_env._menhir_token in
    match _tok with
    | BACKSLASH ->
        _menhir_run4 _menhir_env (Obj.magic _menhir_stack) MenhirState0
    | LBRAC ->
        _menhir_run3 _menhir_env (Obj.magic _menhir_stack) MenhirState0
    | LPAREN ->
        _menhir_run2 _menhir_env (Obj.magic _menhir_stack) MenhirState0
    | VAR _v ->
        _menhir_run1 _menhir_env (Obj.magic _menhir_stack) MenhirState0 _v
    | _ ->
        assert (not _menhir_env._menhir_error);
        _menhir_env._menhir_error <- true;
        _menhir_errorcase _menhir_env (Obj.magic _menhir_stack) MenhirState0) : 'freshtv2))

# 219 "/home/nymphium/.opam/system/lib/menhir/standard.mly"
  


# 652 "parser2.ml"
