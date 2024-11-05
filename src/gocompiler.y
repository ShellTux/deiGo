%{
	#include <stdio.h>
	#include <stdbool.h>

	#include "gocompiler.h"

	DebugMode debugMode = None;
	TreeNode *program;
%}

%token INTEGER
%token<lexeme> IDENTIFIER
%type<node> program

%union {
    TreeNode *node;
    char* id;
}

%locations

%token PACKAGE SEMICOLON BLANKID RETURN AND ASSIGN STAR COMMA
%token DIV EQ GE GT LBRACE LE LPAR LSQ LT CMDARGS
%token MINUS MOD NE NOT OR PLUS RBRACE RPAR RSQ ELSE FOR
%token IF VAR INT FLOAT32 BOOL STRING PRINT PARSEINT FUNC
%token<string> STRLIT2 INTLIT ID REALLIT RESERVED

%type<node> Program Declarations VarDeclaration VarSpec VarSpec2 Type Type2 FuncDeclaration Parameters Parameters2 Parameters3 FuncBody VarsAndStatements
%type<node> Statement StatementAux StatementIfFor StatementCicle Statement3 Statement4 FuncInvocation FuncInvocation2 ParseArgs Expr Expr2 Expr3


%left COMMA
%right ASSIGN
%left OR
%left AND
%left GE LE LT GT EQ NE
%left PLUS MINUS
%left STAR DIV MOD
%right UNARY
%left LPAR RPAR LSQ RSQ LBRACE RBRACE

%start Program

%%

Program: PACKAGE ID SEMICOLON Declarations	{}

Declarations: Declarations VarDeclaration SEMICOLON             {}
            | Declarations FuncDeclaration SEMICOLON            {}
            |                                                   {}
;

VarDeclaration: VAR VarSpec                         {}
            |   VAR LPAR VarSpec SEMICOLON RPAR     {}

;

VarSpec: ID VarSpec2 Type           {}
;



VarSpec2: COMMA ID VarSpec2                   {}
        |                                     {}
;

Type: INT           {}
    | FLOAT32       {}
    | BOOL          {}
    | STRING        {}
;

FuncDeclaration: FUNC ID LPAR Parameters2 RPAR Type2 FuncBody   {}
;

Parameters2: Parameters         {}
;

Type2: Type         {}
    |               {}
;

Parameters: ID Type Parameters3         {}
            |                           {}
;

Parameters3: Parameters3 COMMA ID Type  {}
            |                           {}
;

FuncBody: LBRACE VarsAndStatements RBRACE   {}
;

VarsAndStatements: VarsAndStatements VarDeclaration SEMICOLON {}
                | VarsAndStatements Statement SEMICOLON       {}
                | VarsAndStatements SEMICOLON                 {}
                |                                              {}
;


Statement: ID ASSIGN Expr                                   {}
        | LBRACE StatementAux RBRACE                          {}

        | IF Expr LBRACE StatementIfFor RBRACE Statement3       {}
        | FOR Expr2 LBRACE StatementIfFor RBRACE                {}

        | RETURN Expr2                                      {}
        | FuncInvocation                                    {}
        | ParseArgs                                         {}
        | PRINT LPAR Statement4 RPAR                        {}
        | error                                             {}
;


StatementIfFor: StatementCicle Statement SEMICOLON       {}
            |                                       {}
;

StatementAux: StatementCicle Statement SEMICOLON       {}
		|					{}

;

StatementCicle: StatementCicle Statement SEMICOLON   {}
            |                                       {}
;


Statement3: ELSE LBRACE StatementIfFor RBRACE           {}
            |                                       {}
;

Statement4: Expr            {}
            |STRLIT2         {}
;

Expr2: Expr         {}
        |           {}
;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR      {}
        | ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR                      {}
;

FuncInvocation: ID LPAR FuncInvocation2 RPAR        {}
                |ID LPAR error RPAR                 {}
;

FuncInvocation2: Expr Expr3             {}
                |                       {}
;

Expr3: Expr3 COMMA Expr                 {}
        |                               {}
;

Expr: LPAR Expr RPAR              {}
    	| LPAR error RPAR             {}
	| Expr OR Expr                {}
	| Expr AND Expr               {}
	| Expr LT Expr                {}
	| Expr GT Expr                {}
	| Expr EQ Expr                {}
	| Expr NE Expr                {}
	| Expr LE Expr                {}
	| Expr GE Expr                {}
	| Expr PLUS Expr              {}
	| Expr MINUS Expr             {}
	| Expr STAR Expr              {}
	| Expr DIV Expr               {}
	| Expr MOD Expr          	  {}
	| NOT Expr %prec UNARY        {}
    | MINUS Expr %prec UNARY      {}
    | PLUS Expr %prec UNARY       {}
	| INTLIT                      {}
	| REALLIT                     {}
    	| ID                          {}
	| FuncInvocation              {}


;

%%
int main(int argc, char **argv) {
	for (int i = 1; i < argc; ++i) {
		const char *arg = argv[i];

		if (strcmp("-h", arg) == 0 || strcmp("--help", arg) == 0) {
			usage(argv[0]);
		}

		debugMode |= Lexer * ((strcmp("-l", arg) == 0) ? 1 : 0);
		debugMode |= Parser * ((strcmp("-t", arg) == 0) ? 1 : 0);
	}

	yyparse();
	showNode(program, 0);
	return 0;
}
