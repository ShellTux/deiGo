%{
	struct node *program;

	#include <stdio.h>
	#include <stdbool.h>
	#include "ast.h"
	#include "yy.h"
%}

%token INTEGER
%token<lexeme> IDENTIFIER
%type<node> program

%union {
    char *lexeme;
    struct node *node;
}

%left '+' '-'
%left '*' '/'
%nonassoc '('
%nonassoc IF ELSE THEN

%token NATURAL
%token IF ELSE THEN
%%
calculator: NATURAL { ; }
    ;
%%
