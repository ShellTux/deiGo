%{
	#include <stdio.h>
	#include <stdbool.h>

	#include "gocompiler.h"

	DebugMode debugMode = None;
	TreeNode *programT;
	Node *program = NULL;
%}

// %union {
//     TreeNode *node;
//     char* id;
// }
%union {
	Node *node;
	char *token;
}

%locations

%token AND
%token ASSIGN
%token BLANKID
%token BOOL
%token CMDARGS
%token COMMA
%token DIV
%token ELSE
%token EQ
%token FLOAT32
%token FOR
%token FUNC
%token GE
%token GT
%token IF
%token INT
%token INTEGER
%token LBRACE
%token LE
%token LPAR
%token LSQ
%token LT
%token MINUS
%token MOD
%token NE
%token NOT
%token OR
%token PACKAGE
%token PARSEINT
%token PLUS
%token PRINT
%token RBRACE
%token RETURN
%token RPAR
%token RSQ
%token SEMICOLON
%token STAR
%token STRING
%token VAR

%token<string> IDENTIFIER
%token<string> NATURAL
%token<string> DECIMAL
%token<string> RESERVED
%token<string> STRLIT

%type<node> Declarations
%type<node> Expr
%type<node> Expr2
%type<node> Expr3
%type<node> FuncBody
%type<node> FuncDeclaration
%type<node> FuncInvocation
%type<node> FuncInvocation2
%type<node> Parameters
%type<node> Parameters2
%type<node> Parameters3
%type<node> ParseArgs
%type<node> Program
%type<node> Statement
%type<node> Statement3
%type<node> Statement4
%type<node> StatementAux
%type<node> StatementCicle
%type<node> StatementIfFor
%type<node> Type
%type<node> Type2
%type<node> VarDeclaration
%type<node> VarsAndStatements
%type<node> VarSpec
%type<node> VarSpec2


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

Program: PACKAGE ID SEMICOLON Declarations	{
       $$ = program = createNode(Program, NULL);
       if ($4 != NULL) {
		addChild($$, $4);
       }
   }
   ;

Declarations: /* epsilon */                                         {}
            | VarDeclaration SEMICOLON Declarations                 {}
            | FuncDeclaration SEMICOLON Declarations                {}
            ;


VarDeclaration: VAR VarSpec                                         {}
              | VAR LPAR VarSpec SEMICOLON RPAR                     {}
              ;

VarSpec: ID VarSpecs Type                                           {}
       ;

VarSpecs: COMMA ID VarSpecs                                         {}
        | /* epsilon */                                             {}
        ;

Type: INT                                                           {}
    | FLOAT32                                                       {}
    | BOOL                                                          {}
    | STRING                                                        {}
    ;

FuncDeclaration: FUNC FuncHeader FuncBody                           {}
               ;

FuncHeader: ID LPAR Parameters RPAR Type                            {}
          | ID LPAR Parameters RPAR                                 {}
          ;

Parameters: ParamDecl ParameterList                                 {}
          | /* epsilon */                                           {}
          ;

ParameterList: COMMA ParamDecl ParameterList                        {}
         | /* epsilon */                                            {}
         ;

ParamDecl: ID Type                                                  {}
         ;

FuncBody: LBRACE VarsAndStatements RBRACE                           {}
        ;

VarsAndStatements: /* epsilon */                                    {}
                 |  SEMICOLON VarsAndStatements                     {}
                 |  VarDeclaration SEMICOLON VarsAndStatements      {}
                 |  Statement SEMICOLON VarsAndStatements           {}
                 ;

Statement: ID ASSIGN Expr                                           {}
         | LBRACE StatementList RBRACE                              {}
         | IF Expr BlockProduction                                  {}
         | IF Expr BlockProduction ELSE BlockProduction             {}
         | FOR Expr BlockProduction                                 {}
         | FOR BlockProduction                                      {}
         | RETURN Expr                                              {}
         | RETURN                                                   {}
         | FuncInvocation                                           {}
         | ParseArgs                                                {}
         | PRINT LPAR Expr RPAR                                     {}
         | PRINT LPAR STRLIT RPAR                                   {}
         | error                                                    {}
         ;

BlockProduction: LBRACE StatementList RBRACE                        {}
               ;

StatementList: Statement SEMICOLON StatementList                    {}
             | /* epsilon */                                        {}
             ;

ParseArgs: ID COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR          {}
         | ID COMMA BLANKID ASSIGN PARSEINT LPAR error RPAR                         {}
         ;

FuncInvocation: ID LPAR RPAR                                        {}
              | ID LPAR error RPAR                                  {}
              | ID LPAR Expr FuncInv RPAR                           {}
              ;

FuncInv: COMMA Expr FuncInv                                         {}
       | /* epsilon */                                              {}
       ;

Expr: Expr OR Expr                                                  {}
    | Expr AND Expr                                                 {}
    | Expr LT Expr                                                  {}    
    | Expr GT Expr                                                  {}
    | Expr EQ Expr                                                  {}
    | Expr NE Expr                                                  {}
    | Expr LE Expr                                                  {}
    | Expr GE Expr                                                  {}
    | Expr PLUS Expr                                                {}
    | Expr MINUS Expr                                               {}
    | Expr STAR Expr                                                {}
    | Expr DIV Expr                                                 {}
    | Expr MOD Expr                                                 {}
    | NOT Expr                                                      {}
    | MINUS Expr %prec UNARY                                        {}
    | PLUS Expr %prec UNARY                                         {}
    | INTLIT                                                        {}
    | REALLIT                                                       {}
    | ID                                                            {}
    | FuncInvocation                                                {}
    | LPAR Expr RPAR                                                {}
    | LPAR error RPAR                                               {}
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
	printNode(program, 0);
	return 0;
}
