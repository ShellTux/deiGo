%{
	#include <stdio.h>
	#include <stdbool.h>

	#include "gocompiler.h"

	enum DebugMode debugMode = None;
	TreeNode *programT;
	struct Node *program = NULL;
%}

// %union {
//     TreeNode *node;
//     char* id;
// }
%union {
	struct Node *node;
	struct NodeList *list;
	char *string;
	double decimal;
	int natural;
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

%type<list> Declarations

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

Program: PACKAGE IDENTIFIER SEMICOLON Declarations {
       $$ = program = createNode(Program, NULL);
	addChilds($$, $4);
   }
   ;

Declarations : VarDeclaration SEMICOLON Declarations {
		    addNode(&$$, $1);
		    addNodes(&$$, $3);
		}
	| VarDeclaration SEMICOLON {
		    addNode(&$$, $1);
		}
	| FuncDeclaration SEMICOLON Declarations {
		    addNode(&$$, $1);
		    addNodes(&$$, $3);
		}
	| FuncDeclaration SEMICOLON {
			addNode(&$$, $1);
		}
;

VarDeclaration: VAR VarSpec {
			$$ = $2;
		      }
	      | VAR LPAR VarSpec SEMICOLON RPAR {
			$$ = $3;
		      }
	;

VarSpec: IDENTIFIER VarSpecs Type {}
       ;

VarSpecs: COMMA IDENTIFIER VarSpecs {}
	| {}
	;

Type: INT     { $$ = createNode(Int, NULL); }
    | FLOAT32 { $$ = createNode(Float32, NULL); }
    | BOOL    { $$ = createNode(Bool, NULL); }
    | STRING  { $$ = createNode(String, NULL); }
    ;

FuncDeclaration: FUNC FuncHeader FuncBody {}
	       ;

FuncHeader: IDENTIFIER LPAR Parameters RPAR Type {}
	  | IDENTIFIER LPAR Parameters RPAR {}
	  ;

FuncBody: LBRACE VarsAndStatements RBRACE {}
	;

Parameters: ParamDecl ParameterList {}
	  | {}
	  ;

ParameterList: COMMA ParamDecl ParameterList {}
         | /* epsilon */ {}
         ;

ParamDecl: IDENTIFIER Type {}
         ;

VarsAndStatements: /* epsilon */ {}
                 |  SEMICOLON VarsAndStatements {}
                 |  VarDeclaration SEMICOLON VarsAndStatements {}
                 |  Statement SEMICOLON VarsAndStatements {}
                 ;

Statement: IDENTIFIER ASSIGN Expr {}
         | LBRACE StatementList RBRACE {}
         | IF Expr BlockProduction {}
         | IF Expr BlockProduction ELSE BlockProduction {}
         | FOR Expr BlockProduction {}
         | FOR BlockProduction {}
         | RETURN Expr {}
         | RETURN {}
         | FuncInvocation {}
         | ParseArgs {}
         | PRINT LPAR Expr RPAR {}
         | PRINT LPAR STRLIT RPAR {}
         | error {}
         ;

ParseArgs: IDENTIFIER COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR {}
	 ;

FuncInvocation: IDENTIFIER LPAR RPAR {}
              | IDENTIFIER LPAR error RPAR {}
              | IDENTIFIER LPAR Expr ExprList RPAR {}
              ;

ExprList: COMMA Expr ExprList {}
	| {}
	;

Expr: Expr OR Expr           { $$ = createNode(Or, NULL);    addChild($$, $1); addChild($$, $3); }
    | Expr AND Expr          { $$ = createNode(And, NULL);   addChild($$, $1); addChild($$, $3); }
    | Expr LT Expr           { $$ = createNode(Lt, NULL);    addChild($$, $1); addChild($$, $3); }
    | Expr GT Expr           { $$ = createNode(Gt, NULL);    addChild($$, $1); addChild($$, $3); }
    | Expr EQ Expr           { $$ = createNode(Eq, NULL);    addChild($$, $1); addChild($$, $3); }
    | Expr NE Expr           { $$ = createNode(Ne, NULL);    addChild($$, $1); addChild($$, $3); }
    | Expr LE Expr           { $$ = createNode(Le, NULL);    addChild($$, $1); addChild($$, $3); }
    | Expr GE Expr           { $$ = createNode(Ge, NULL);    addChild($$, $1); addChild($$, $3); }
    | Expr PLUS Expr         { $$ = createNode(Plus, NULL);  addChild($$, $1); addChild($$, $3); }
    | Expr MINUS Expr        { $$ = createNode(Minus, NULL); addChild($$, $1); addChild($$, $3); }
    | Expr STAR Expr         { $$ = createNode(Star, NULL);  addChild($$, $1); addChild($$, $3); }
    | Expr DIV Expr          { $$ = createNode(Div, NULL);   addChild($$, $1); addChild($$, $3); }
    | Expr MOD Expr          { $$ = createNode(Mod, NULL);   addChild($$, $1); addChild($$, $3); }
    | NOT Expr               { $$ = createNode(Not, NULL);   addChild($$, $2); }
    | MINUS Expr %prec UNARY { $$ = createNode(Not, NULL);   addChild($$, $2); }
    | PLUS Expr %prec UNARY  { $$ = createNode(Not, NULL);   addChild($$, $2); }
    | NATURAL                { $$ = createNode(Natural, $1); }
    | DECIMAL                { $$ = createNode(Natural, $1); }
    | IDENTIFIER             { $$ = createNode(Natural, $1); }
    | FuncInvocation         { $$ = $1; }
    | LPAR Expr RPAR         { $$ = $2; }
    | LPAR error RPAR        { }
    ;

BlockProduction: LBRACE StatementList RBRACE {}
               ;

StatementList: Statement SEMICOLON StatementList                    {}
             | /* epsilon */                                        {}
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

#ifdef AST_DEMO
	// Program
	// ..FuncDecl
	// ....FuncHeader                            |
	// ......Identifier(main)    | Parameters    | Func
	// ......FuncParams          |               |
	// ......Identifier(main)    | Parameters2   |
	// ......FuncParams          |               |
	// ....FuncBody                              |
	program = createNode(Program, NULL);
	struct Node *funcDecl = addChild(program, createNode(FuncDecl, NULL));

	struct NodeList *func = NULL;
	struct Node *funcHeader = addNode(&func, createNode(FuncHeader, NULL));
	addNode(&func, createNode(FuncBody, NULL));

	addChilds(funcDecl, func);

	struct NodeList *params = NULL;
	addNode(&params, createNode(Identifier, "main"));
	addNode(&params, createNode(FuncParams, NULL));

	struct NodeList *params2 = NULL;
	addNode(&params2, createNode(Identifier, "main"));
	addNode(&params2, createNode(FuncParams, NULL));

	addNodes(&params, params2);

	addChilds(funcHeader, params);


	printNode(program, 0);
#else
#ifdef DEBUG
	yydebug = 1;
#endif
	yyparse();

	if (debugMode & Parser) {
		printNode(program, 0);
	}
#endif
	return 0;
}
