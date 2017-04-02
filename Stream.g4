grammar Stream;

tokens { INDENT, DEDENT }

WS : [ \t\n\r]+ -> skip;

main
    : body
    ;

block
    : LBRACE body RBRACE # MajorBlock
    | LBRACKET body RBRACKET # MinorBlock
    | LPAREN body RPAREN # ImmediateBlock
    ;

body
    : statement # CreateBlock
    | body STMT_TERM statement # AddBlock
    ;

statement
    : l_value ASSIGN r_value # ExplicitAssignment
    | l_value LASSIGN r_value # ExplicitAssignment
    | r_value RASSIGN l_value # ExplicitAssignment
    | r_value # ImplicitAssignment
    | /* empty */ # EmptyStatement
    ;

l_value
    : /* empty */
    | identifier
    ;

r_value
    : composition
    | left_flow
    | right_flow
    ;

left_flow
    : composition LMAP composition
    | composition LCALL composition
    | composition LMAP left_flow
    | composition LCALL left_flow
    ;

right_flow
    : composition RMAP composition
    | composition RCALL composition
    | right_flow RMAP composition
    | right_flow RCALL composition
    ;

composition
    : func_expr
    | composition COMPOSE func_expr
    ;

func_expr
    : molecule
    | func_expr molecule
    | func_expr IDENT PAIR_SEP molecule
    ;

molecule
    : atom
    | molecule PROP_ACCESS IDENT
    ;

atom
    : NUMBER
    | STRING
    | SCRIBBLE
    | identifier
    | block
    ;

identifier
    : IDENT
    | PUBLIC_MOD IDENT
    | PRIVATE_MOD IDENT
    | UNBOUND_MOD IDENT
    | CARET_MOD IDENT
    ;

IDENT : [a-zA-Z_] [a-zA-Z0-9_]*;
NUMBER : [0-9]+;
STRING : '\'' [a-zA-Z0-9_]* '\'';
SCRIBBLE : '"' [a-zA-Z0-9_]* '"';

STMT_TERM : '\n' | ',';

LBRACE : '{';
RBRACE : '}';
LBRACKET : '[';
RBRACKET : ']';
LPAREN : '(';
RPAREN : ')';

ASSIGN : '=';
LASSIGN : '<=';
RASSIGN : '=>';

LMAP : '<-';
RMAP : '->';
LCALL : '<|';
RCALL : '|>';

COMPOSE : '*';
PAIR_SEP : ':';
PROP_ACCESS : '.';

PUBLIC_MOD : '+';
PRIVATE_MOD : '-';
UNBOUND_MOD : '.';
CARET_MOD : '^';
