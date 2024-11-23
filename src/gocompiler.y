/* João Fonseca 2021227194 */
/* Luís Pedro de Sousa Oliveira Góis 2018280716 */
/***************************************************************************
 * Project                                           _      _  ____
 *                                                __| | ___(_)/ ___| ___
 *                                               / _` |/ _ \ | |  _ / _ \
 *                                              | (_| |  __/ | |_| | (_) |
 *                                               \__,_|\___|_|\____|\___/
 *
 *
 *
 * Authors: João Fonseca, Luís Góis
 *
 * This software is licensed as described in the file LICENSE, which
 * you should have received as part of this distribution.
 *
 * You may opt to use, copy, modify, merge, publish, distribute and/or sell
 * copies of the Software, and permit persons to whom the Software is
 * furnished to do so, under the terms of the LICENSE file.
 *
 * This software is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY
 * KIND, either express or implied.
 *
 ***************************************************************************/
%{
	#include <stdio.h>
	#include <stdbool.h>
        #include <string.h>

        #include "gocompiler.h"
        #include "parser.h"

	void debugSyntaxRule(const char *rule, const struct Node *node, const struct NodeList *list);

	extern enum DebugMode debugMode;
	extern struct Errors errors;
	extern struct Node *program;
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
%type<list> VarSpecs

%type<node> Expr
%type<node> FuncBody
%type<node> FuncDeclaration
%type<node> FuncHeader
%type<node> FuncInvocation
%type<node> FuncParams
%type<node> ParamDecl
%type<node> ParseArgs
%type<node> Program
%type<node> Statement
%type<node> Type
%type<node> VarDeclaration

%left OR
%left AND
%left GE LE LT GT EQ NE
%left PLUS MINUS
%left STAR DIV MOD
%precedence UNARY

%start Program

%%

Program: PACKAGE IDENTIFIER SEMICOLON Declarations {
        $$ = program = createNode(Program, NULL);
        addChilds($$, $4);
        debugSyntaxRule("Program -> PACKAGE IDENTIFIER SEMICOLON Declarations", $$, NULL);
    }
;

Declarations: VarDeclaration SEMICOLON Declarations {
        $$ = createNodeList($1);
        addNodes($$, $3);
        debugSyntaxRule("Declarations -> VarDeclaration SEMICOLON Declarations", NULL, $$);
    }
    | FuncDeclaration SEMICOLON Declarations {
        $$ = createNodeList($1);
        addNodes($$, $3);
        debugSyntaxRule("Declarations -> FuncDeclaration SEMICOLON Declarations", NULL, $$);
    }
    | /* ϵ */ %empty { $$ = createNodeList(NULL); debugSyntaxRule("Declarations -> ε", NULL, $$); }
;

VarDeclaration: VAR IDENTIFIER VarSpecs Type {
        $$ = createNode(VarDecl, NULL);
        addChild($$, $4);
        addChild($$, createNode(Identifier, $2));
        addChilds($$, $3);
        debugSyntaxRule("VarDeclaration -> VAR IDENTIFIER VarSpecs Type", $$, NULL);
    }
    | VAR LPAR IDENTIFIER VarSpecs Type SEMICOLON RPAR {
        $$ = createNode(VarDecl, NULL);
        addChild($$, $5);
        addChild($$, createNode(Identifier, $3));
        addChilds($$, $4);
        debugSyntaxRule("VarDeclaration -> VAR LPAR IDENTIFIER VarSpecs Type SEMICOLON RPAR", $$, NULL);
    }
;


VarSpecs: COMMA IDENTIFIER VarSpecs {
        $$ = createNodeList(NULL);
        addNodes($$, $3);
        debugSyntaxRule("VarSpecs -> COMMA IDENTIFIER VarSpecs", NULL, $$);
    }
    | /* ϵ */ %empty { $$ = createNodeList(NULL); debugSyntaxRule("VarSpecs -> ε", NULL, $$); }
;

Type: INT     { $$ = createNode(Int,     NULL); debugSyntaxRule("Type -> INT",     $$, NULL); }
    | FLOAT32 { $$ = createNode(Float32, NULL); debugSyntaxRule("Type -> Float32", $$, NULL); }
    | BOOL    { $$ = createNode(Bool,    NULL); debugSyntaxRule("Type -> Bool",    $$, NULL); }
    | STRING  { $$ = createNode(String,  NULL); debugSyntaxRule("Type -> String",  $$, NULL); }
;

FuncDeclaration: FUNC FuncHeader FuncBody {
        $$ = createNode(FuncDecl, NULL);
        addChild($$, $2);
        addChild($$, $3);
        debugSyntaxRule("FuncDeclaration -> FUNC FuncHeader FuncBody", $$, NULL);
    }
;

FuncHeader: IDENTIFIER LPAR FuncParams RPAR Type {
        $$ = createNode(FuncHeader, NULL);
        addChild($$, createNode(Identifier, $1));
        addChild($$, $5);
        addChild($$, $3);
        debugSyntaxRule("FuncHeader -> IDENTIFIER LPAR FuncParams RPAR Type", $$, NULL);
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
        debugSyntaxRule("FuncParams -> ParamDecl FuncParamsList", $$, NULL);
    }
    | /* ϵ */ %empty { $$ = createNode(FuncParams, NULL); debugSyntaxRule("FuncParams -> ε", $$, NULL); }
;

FuncParamsList: COMMA ParamDecl FuncParamsList {
        $$ = createNodeList($2);
        addNodes($$, $3);
        debugSyntaxRule("FuncParamsList -> COMMA ParamDecl FuncParamsList", NULL, $$);
    }
    | /* ϵ */ %empty { $$ = createNodeList(NULL); debugSyntaxRule("FuncParamsList -> ε", NULL, $$); }
;

ParamDecl: IDENTIFIER Type {
        $$ = createNode(ParamDecl, NULL);
        addChild($$, $2);
        addChild($$, createNode(Identifier, $1));
        debugSyntaxRule("ParamDecl -> IDENTIFIER Type", $$, NULL);
    }
;

VarsAndStatements: /* ϵ */ %empty { $$ = createNodeList(NULL); debugSyntaxRule("VarsAndStatements -> ε", NULL, $$); }
    | VarDeclaration SEMICOLON VarsAndStatements {
        $$ = createNodeList($1);
        addNodes($$, $3);
        debugSyntaxRule("VarsAndStatements -> VarDeclaration SEMICOLON VarsAndStatements", NULL, $$);
    }
    | Statement SEMICOLON VarsAndStatements {
        $$ = createNodeList($1);
        addNodes($$, $3);
        debugSyntaxRule("VarsAndStatements -> Statement SEMICOLON VarsAndStatements", NULL, $$);
    }
;

Statement: IDENTIFIER ASSIGN Expr {
        $$ = createNode(Assign, NULL);
        addChild($$, createNode(Identifier, $1));
        addChild($$, $3);
        debugSyntaxRule("Statement -> IDENTIFIER ASSIGN Expr", $$, NULL);
    }
    | LBRACE StatementList RBRACE {
        $$ = createNode(Block, NULL);
        addChilds($$, $2);
        debugSyntaxRule("Statement -> LBRACE StatementList RBRACE", $$, NULL);
    }
    | IF Expr BlockProduction {
        $$ = createNode(If, NULL);
        addChild($$, $2);
        addChilds($$, $3);
        debugSyntaxRule("Statement -> IF Expr BlockProduction", $$, NULL);
    }
    | IF Expr BlockProduction ELSE BlockProduction {
        $$ = createNode(If, NULL);
        addChild($$, $2);
        addChilds($$, $3);
        addChilds($$, $5);
        debugSyntaxRule("Statement -> IF Expr BlockProduction ELSE BlockProduction", $$, NULL);
    }
    | FOR Expr BlockProduction {
        $$ = createNode(For, NULL);
        addChild($$, $2);
        addChilds($$, $3);
        debugSyntaxRule("Statement -> FOR Expr BlockProduction", $$, NULL);
    }
    | FOR BlockProduction {
        $$ = createNode(For, NULL);
        addChilds($$, $2);
        debugSyntaxRule("Statement -> FOR BlockProduction", $$, NULL);
    }
    | RETURN Expr {
        $$ = createNode(Return, NULL);
        addChild($$, $2);
        debugSyntaxRule("Statement -> RETURN Expr", $$, NULL);
    }
    | PRINT LPAR Expr RPAR {
        $$ = createNode(Print, NULL);
        addChild($$, $3);
        debugSyntaxRule("Statement -> PRINT LPAR Expr RPAR", $$, NULL);
    }
    | RETURN                 { $$ = createNode(Return, NULL); debugSyntaxRule("Statement -> RETURN", $$, NULL); }
    | FuncInvocation         { $$ = $1;                       debugSyntaxRule("Statement -> FuncInvocation", $$, NULL); }
    | ParseArgs              { $$ = $1;                       debugSyntaxRule("Statement -> ParseArgs", $$, NULL); }
    | PRINT LPAR STRLIT RPAR {
        $$ = createNode(Print, NULL);
        addChild($$, createNode(StrLit, $3));
        debugSyntaxRule("Statement -> PRINT LPAR STRLIT RPAR", $$, NULL);
    }
    | error                  { errors.syntax++; }
;


ParseArgs: IDENTIFIER COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR {
        $$ = createNode(ParseArgs, NULL);
        addChild($$, createNode(Identifier, $1));
        addChild($$, $9);
        debugSyntaxRule("ParseArgs -> IDENTIFIER COMMA BLANKID ASSIGN PARSEINT LPAR CMDARGS LSQ Expr RSQ RPAR", $$, NULL);
    }
;


FuncInvocation: IDENTIFIER LPAR RPAR {
        $$ = createNode(Call, NULL);
        addChild($$, createNode(Identifier, $1));
        debugSyntaxRule("FuncInvocation -> IDENTIFIER LPAR RPAR", $$, NULL);
    }
    | IDENTIFIER LPAR Expr ExprList RPAR {
        $$ = createNode(Call, NULL);
        addChild($$, createNode(Identifier, $1));
        addChild($$, $3);
        addChilds($$, $4);
        debugSyntaxRule("IDENTIFIER LPAR Expr ExprList RPAR", $$, NULL);
    }
    | IDENTIFIER LPAR error RPAR { errors.syntax++; }
;

ExprList: ExprList COMMA Expr {
        $$ = createNodeList($3);
        addNodes($$, $1);
        debugSyntaxRule("ExprList -> ExprList COMMA Expr", NULL, $$);
    }
    | /* ϵ */ %empty { $$ = createNodeList(NULL); debugSyntaxRule("ExprList -> ε", NULL, $$); }
;

Expr: Expr OR Expr {
        $$ = createNode(Or, NULL);
        addChild($$, $1);
        addChild($$, $3);
        debugSyntaxRule("Expr -> Expr OR Expr", $$, NULL);
    }
    | Expr AND Expr {
        $$ = createNode(And, NULL);
        addChild($$, $1);
        addChild($$, $3);
        debugSyntaxRule("Expr -> Expr AND Expr", $$, NULL);
    }
    | Expr LT Expr {
        $$ = createNode(Lt, NULL);
        addChild($$, $1);
        addChild($$, $3);
        debugSyntaxRule("Expr -> Expr LT Expr", $$, NULL);
    }
    | Expr GT Expr {
        $$ = createNode(Gt, NULL);
        addChild($$, $1);
        addChild($$, $3);
        debugSyntaxRule("Expr -> Expr GT Expr", $$, NULL);
    }
    | Expr EQ Expr {
        $$ = createNode(Eq, NULL);
        addChild($$, $1);
        addChild($$, $3);
        debugSyntaxRule("Expr -> Expr EQ Expr", $$, NULL);
    }
    | Expr NE Expr {
        $$ = createNode(Ne, NULL);
        addChild($$, $1);
        addChild($$, $3);
        debugSyntaxRule("Expr -> Expr NE Expr", $$, NULL);
    }
    | Expr LE Expr {
        $$ = createNode(Le, NULL);
        addChild($$, $1);
        addChild($$, $3);
        debugSyntaxRule("Expr -> Expr LE Expr", $$, NULL);
    }
    | Expr GE Expr {
        $$ = createNode(Ge, NULL);
        addChild($$, $1);
        addChild($$, $3);
        debugSyntaxRule("Expr -> Expr GE Expr", $$, NULL);
    }
    | Expr PLUS Expr {
        $$ = createNode(Add, NULL);
        addChild($$, $1);
        addChild($$, $3);
        debugSyntaxRule("Expr -> Expr PLUS Expr", $$, NULL);
    }
    | Expr MINUS Expr {
        $$ = createNode(Sub, NULL);
        addChild($$, $1);
        addChild($$, $3);
        debugSyntaxRule("Expr -> Expr MINUS Expr", $$, NULL);
    }
    | Expr STAR Expr {
        $$ = createNode(Mul, NULL);
        addChild($$, $1);
        addChild($$, $3);
        debugSyntaxRule("Expr -> Expr STAR Expr", $$, NULL);
    }
    | Expr DIV Expr {
        $$ = createNode(Div, NULL);
        addChild($$, $1);
        addChild($$, $3);
        debugSyntaxRule("Expr -> Expr DIV Expr", $$, NULL);
    }
    | Expr MOD Expr {
        $$ = createNode(Mod, NULL);
        addChild($$, $1);
        addChild($$, $3);
        debugSyntaxRule("Expr -> Expr MOD Expr", $$, NULL);
    }
    | NOT Expr %prec UNARY {
        $$ = createNode(Not, NULL);
        addChild($$, $2);
        debugSyntaxRule("Expr -> NOT Expr \%prec UNARY", $$, NULL);
    }
    | MINUS Expr %prec UNARY {
        $$ = createNode(Minus, NULL);
        addChild($$, $2);
        debugSyntaxRule("Expr -> MINUS Expr \%prec UNARY", $$, NULL);
    }
    | PLUS Expr %prec UNARY {
        $$ = createNode(Plus, NULL);
        addChild($$, $2);
        debugSyntaxRule("Expr -> PLUS Expr \%prec UNARY", $$, NULL);
    }
    | NATURAL         { $$ = createNode(Natural, $1);    debugSyntaxRule("Expr -> NATURAL", $$, NULL); }
    | DECIMAL         { $$ = createNode(Decimal, $1);    debugSyntaxRule("Expr -> DECIMAL", $$, NULL); }
    | IDENTIFIER      { $$ = createNode(Identifier, $1); debugSyntaxRule("Expr -> IDENTIFIER", $$, NULL); }
    | FuncInvocation  { $$ = $1;                         debugSyntaxRule("Expr -> FuncInvocation", $$, NULL); }
    | LPAR Expr RPAR  { $$ = $2;                         debugSyntaxRule("Expr -> LPAR Expr RPAR", $$, NULL); }
    | LPAR error RPAR { $$ = NULL; errors.syntax++; }
;

BlockProduction: LBRACE StatementList RBRACE {
        struct Node *block = createNode(Block, NULL);
        addChilds(block, $2);
        struct NodeList *blockList = createNodeList(block);
        addNode(blockList, createNode(Block, NULL));
        $$ = blockList;
        debugSyntaxRule("BlockProduction -> LBRACE StatementList RBRACE", NULL, $$);
    }
;

StatementList: Statement SEMICOLON StatementList {
        $$ = createNodeList($1);
        addNodes($$, $3);
        debugSyntaxRule("StatementList -> Statement SEMICOLON StatementList", NULL, $$);
    }
    | /* ϵ */ %empty { $$ = createNodeList(NULL); debugSyntaxRule("StatementList -> ε", NULL, $$); }
;

%%

void debugSyntaxRule(const char *rule, const struct Node *node, const struct NodeList *list) {
#ifndef DEBUG
	(void) rule;
	(void) node;
	(void) list;
#else
	if (rule == NULL) {
		return;
	}

	printf("%s\n", rule);
	printNode(node, 0);
	printNodeList(list, 0);

	printf("\n");
#endif
}
// vim: expandtab:shiftwidth=4:softtabstop=4:smartindent
