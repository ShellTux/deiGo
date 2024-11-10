%{
	#include <stdio.h>
	#include <stdbool.h>

	#include "gocompiler.h"

	enum DebugMode debugMode = None;
	struct Node *program = NULL;
%}

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

%token<string> DECIMAL
%token<string> IDENTIFIER
%token<string> NATURAL
%token<string> RESERVED
%token<string> STRLIT

%type<list> BlockProduction
%type<list> Declarations
%type<list> ExprList
%type<list> FuncParamsList
%type<list> StatementList
%type<list> VarsAndStatements
%type<list> VarSpec
%type<list> VarSpecs

%type<node> Expr
%type<node> FuncBody
%type<node> FuncDeclaration
%type<node> FuncHeader
%type<node> FuncInvocation
%type<node> FuncParams
%type<node> ParamDecl
%type<node> Program
%type<node> Statement
%type<node> Type
%type<node> VarDeclaration


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
           $$ = createNode(Program, NULL);
           addChilds($$, $4);
       }
   ;

Declarations: VarDeclaration SEMICOLON Declarations {
		 $$ = createNodeList($1);
		 addNodes($$, $3);
              }
              | FuncDeclaration SEMICOLON Declarations {
		 $$ = createNodeList($1);
		 addNodes($$, $3);
              }
              | VarDeclaration SEMICOLON {
		 $$ = createNodeList($1);
              }
              | FuncDeclaration SEMICOLON {
		 $$ = createNodeList($1);
              }
              | /* epsilon */ { $$ = createNodeList(NULL); }
;

VarDeclaration: VAR VarSpec {
                     $$ = createNode(VarDecl, NULL);
                     addChilds($$, $2);
                 }
              | VAR LPAR VarSpec SEMICOLON RPAR {
                     $$ = createNode(VarDecl, NULL);
                     addChilds($$, $3);
                 }
;

VarSpec: IDENTIFIER VarSpecs Type {
	   $$ = createNodeList(createNode(Identifier, $1));
           // addNodes(&$$, $3);
        }
;

VarSpecs: COMMA IDENTIFIER VarSpecs {
	      $$ = createNodeList(createNode(Identifier, $2));
              addNodes($$, $3);
          }
         | /* epsilon */ { $$ = createNodeList(NULL); }
;

Type: INT {
          $$ = createNode(Int, NULL);
      }
    | FLOAT32 {
          $$ = createNode(Float32, NULL);
      }
    | BOOL {
          $$ = createNode(Bool, NULL);
      }
    | STRING {
          $$ = createNode(String, NULL);
      }
;

FuncDeclaration: FUNC FuncHeader FuncBody {
                    $$ = createNode(FuncDecl, NULL);
                    addChild($$, $2);
                    addChild($$, $3);
                }
;

FuncHeader: IDENTIFIER LPAR FuncParams RPAR Type {
               $$ = createNode(FuncHeader, NULL);
               addChild($$, createNode(Identifier, $1));
               addChild($$, $3);
               addChild($$, $5);
           }
          | IDENTIFIER LPAR FuncParams RPAR {
               $$ = createNode(FuncHeader, NULL);
               addChild($$, createNode(Identifier, $1));
               addChild($$, $3);
	       debugSyntaxRule("FuncHeader -> IDENTIFIER LPAR FuncParams RPAR", $$, NULL);
           }
;

FuncBody: LBRACE VarsAndStatements RBRACE {
              $$ = createNode(FuncBody, NULL);
              addChilds($$, $2);
	      debugSyntaxRule("FuncBody -> LBRACE VarsAndStatements RBRACE", $$, NULL);
          }
;

FuncParams: ParamDecl FuncParamsList {
	  	$$ = createNode(FuncParams, NULL);
		addChild($$, $1);
                addChilds($$, $2);
            }
          | /* epsilon */ { $$ = createNode(FuncParams, NULL); }
;

FuncParamsList: COMMA ParamDecl FuncParamsList {
		      $$ = createNodeList($2);
		      addNodes($$, $3);
               }
             | /* epsilon */ { $$ = createNodeList(NULL); }
;

ParamDecl: IDENTIFIER Type {
              $$ = createNode(ParamDecl, NULL);
              addChild($$, createNode(Identifier, $1));
              addChild($$, $2);
          }
;

VarsAndStatements: /* epsilon */ { $$ = createNodeList(NULL); }
                 | VarDeclaration SEMICOLON VarsAndStatements {
		     $$ = createNodeList($1);
                     addNodes($$, $3);
                 }
                 | Statement SEMICOLON VarsAndStatements {
		     $$ = createNodeList($1);
		     addNodes($$, $3);
                 }
;

Statement: IDENTIFIER ASSIGN Expr {
                 $$ = createNode(Assign, NULL);
                 addChild($$, createNode(Identifier, $1));
                 addChild($$, $3);
             }
          | LBRACE StatementList RBRACE {
                 $$ = createNode(Block, NULL);
                 addChilds($$, $2);
             }
          | IF Expr BlockProduction {
                 $$ = createNode(If, NULL);
                 addChild($$, $2);
                 addChilds($$, $3);
             }
          | IF Expr BlockProduction ELSE BlockProduction {
                 $$ = createNode(If, NULL);
                 addChild($$, $2);
                 addChilds($$, $3);
                 addChilds($$, $5);
             }
          | FOR Expr BlockProduction {
                 $$ = createNode(For, NULL);
                 addChild($$, $2);
                 addChilds($$, $3);
             }
          | FOR BlockProduction {
                 $$ = createNode(For, NULL);
                 addChilds($$, $2);
             }
          | RETURN Expr {
                 $$ = createNode(Return, NULL);
                 addChild($$, $2);
             }
          | RETURN {
                 $$ = createNode(Return, NULL);
             }
          | FuncInvocation {
                 $$ = $1;
             }
          | PRINT LPAR Expr RPAR {
                 $$ = createNode(Print, NULL);
                 addChild($$, $3);
             }
          | PRINT LPAR STRLIT RPAR {
                 $$ = createNode(StrLit, $3);
             }
          | error {
                 // $$ = createNode(ErrorNode, NULL);
             }
;

FuncInvocation: IDENTIFIER LPAR RPAR {
                   $$ = createNode(Call, NULL);
                   addChild($$, createNode(Identifier, $1));
               }
              | IDENTIFIER LPAR error RPAR {
                   // $$ = createNode(Call, NULL);
                   // addChild($$, createNode(Identifier, $1));
               }
              | IDENTIFIER LPAR Expr ExprList RPAR {
                   $$ = createNode(Call, NULL);
                   addChild($$, createNode(Identifier, $1));
                   addChild($$, $3);
                   addChilds($$, $4);
               }
;

ExprList: COMMA Expr ExprList {
	      $$ = createNodeList($2);
              addNodes($$, $3);
          }
         | /* epsilon */ { $$ = createNodeList(NULL); }
;

Expr: Expr OR Expr {
           $$ = createNode(Or, NULL);
           addChild($$, $1);
           addChild($$, $3);
       }
    | Expr AND Expr {
           $$ = createNode(And, NULL);
           addChild($$, $1);
           addChild($$, $3);
       }
    | Expr LT Expr {
           $$ = createNode(Lt, NULL);
           addChild($$, $1);
           addChild($$, $3);
       }
    | Expr GT Expr {
           $$ = createNode(Gt, NULL);
           addChild($$, $1);
           addChild($$, $3);
       }
    | Expr EQ Expr {
           $$ = createNode(Eq, NULL);
           addChild($$, $1);
           addChild($$, $3);
       }
    | Expr NE Expr {
           $$ = createNode(Ne, NULL);
           addChild($$, $1);
           addChild($$, $3);
       }
    | Expr LE Expr {
           $$ = createNode(Le, NULL);
           addChild($$, $1);
           addChild($$, $3);
       }
    | Expr GE Expr {
           $$ = createNode(Ge, NULL);
           addChild($$, $1);
           addChild($$, $3);
       }
    | Expr PLUS Expr {
           $$ = createNode(Plus, NULL);
           addChild($$, $1);
           addChild($$, $3);
       }
    | Expr MINUS Expr {
           $$ = createNode(Minus, NULL);
           addChild($$, $1);
           addChild($$, $3);
       }
    | Expr STAR Expr {
           $$ = createNode(Star, NULL);
           addChild($$, $1);
           addChild($$, $3);
       }
    | Expr DIV Expr {
           $$ = createNode(Div, NULL);
           addChild($$, $1);
           addChild($$, $3);
       }
    | Expr MOD Expr {
           $$ = createNode(Mod, NULL);
           addChild($$, $1);
           addChild($$, $3);
       }
    | NOT Expr {
           $$ = createNode(Not, NULL);
           addChild($$, $2);
       }
    | MINUS Expr %prec UNARY {
           $$ = createNode(Minus, NULL);
           addChild($$, $2);
       }
    | PLUS Expr %prec UNARY {
           $$ = createNode(Plus, NULL);
           addChild($$, $2);
       }
    | NATURAL {
           $$ = createNode(Natural, $1);
       }
    | IDENTIFIER {
           $$ = createNode(Identifier, $1);
       }
    | FuncInvocation {
           $$ = $1; // Inheriting FuncInvocation's structure
       }
    | LPAR Expr RPAR {
           $$ = $2;
       }
    | LPAR error RPAR {
           // $$ = createNode(ErrorNode, NULL);
       }
;

BlockProduction: LBRACE StatementList RBRACE {
		   $$ = $2;
               }
;

StatementList: Statement SEMICOLON StatementList {
		  $$ = createNodeList($1);
                  addNodes($$, $3);
              }
              | /* epsilon */ { $$ = createNodeList(NULL); }
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
