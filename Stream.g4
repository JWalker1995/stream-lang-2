grammar Stream;

tokens { INDENT, DEDENT }

WS : [ \t\n\r]+ -> skip;

main
    : body # MainBody
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
    : lValue ASSIGN rValue # AssignmentStatement
    | lValue LASSIGN rValue # AssignmentStatement
    | rValue RASSIGN lValue # AssignmentStatement
    | rValue # ExpressionStatement
    | /* empty */ # EmptyStatement
    ;

lValue
    : /* empty */ # ImplicitLValue
    | identifier # IdentifierLValue
    ;

rValue
    : composition
    | leftFlow
    | rightFlow
    ;

leftFlow
    : composition LMAP composition
    | composition LCALL composition
    | composition LMAP leftFlow
    | composition LCALL leftFlow
    ;

rightFlow
    : composition RMAP composition
    | composition RCALL composition
    | rightFlow RMAP composition
    | rightFlow RCALL composition
    ;

composition
    : funcExpr
    | composition COMPOSE funcExpr
    ;

funcExpr
    : molecule
    | funcExpr molecule
    | funcExpr IDENT PAIR_SEP molecule
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
    | SLASH_MOD IDENT
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
SLASH_MOD : '/';
