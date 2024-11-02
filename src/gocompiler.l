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
    #include <ctype.h>
    #include <stdbool.h>
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    #include "yy.h"

    typedef struct {
	    char *buffer;
	    size_t length;
	    size_t capacity;
    } String;

    void stringAppend(String *dest, const char *src);
    void stringDestroy(String *string);

    String string = {0};
    bool isValidString = false;

    #define TOKENS_WITHOUT_FORMAT \
	    TOKEN(SEMICOLON, "SEMICOLON") \
	    TOKEN(COMMA, "COMMA") \
	    TOKEN(BLANKID, "BLANKID") \
	    TOKEN(ASSIGN, "ASSIGN") \
	    TOKEN(STAR, "STAR") \
	    TOKEN(DIV, "DIV") \
	    TOKEN(MINUS, "MINUS") \
	    TOKEN(PLUS, "PLUS") \
	    TOKEN(EQ, "EQ") \
	    TOKEN(GE, "GE") \
	    TOKEN(GT, "GT") \
	    TOKEN(LBRACE, "LBRACE") \
	    TOKEN(LE, "LE") \
	    TOKEN(LPAR, "LPAR") \
	    TOKEN(LSQ, "LSQ") \
	    TOKEN(LT, "LT") \
	    TOKEN(MOD, "MOD") \
	    TOKEN(NE, "NE") \
	    TOKEN(NOT, "NOT") \
	    TOKEN(AND, "AND") \
	    TOKEN(OR, "OR") \
	    TOKEN(RBRACE, "RBRACE") \
	    TOKEN(RPAR, "RPAR") \
	    TOKEN(RSQ, "RSQ") \
	    TOKEN(PACKAGE, "PACKAGE") \
	    TOKEN(RETURN, "RETURN") \
	    TOKEN(ELSE, "ELSE") \
	    TOKEN(FOR, "FOR") \
	    TOKEN(IF, "IF") \
	    TOKEN(VAR, "VAR") \
	    TOKEN(INT, "INT") \
	    TOKEN(FLOAT32, "FLOAT32") \
	    TOKEN(BOOL, "BOOL") \
	    TOKEN(STRING, "STRING") \
	    TOKEN(PRINT, "PRINT") \
	    TOKEN(PARSEINT, "PARSEINT") \
	    TOKEN(FUNC, "FUNC") \
	    TOKEN(CMDARGS, "CMDARGS")
	#define TOKENS_WITH_FORMAT \
	    TOKEN(RESERVED, "RESERVED(%s)") \
	    TOKEN(NATURAL, "NATURAL(%s)") \
	    TOKEN(DECIMAL, "DECIMAL(%s)") \
	    TOKEN(IDENTIFIER, "IDENTIFIER(%s)") \
	    TOKEN(STRLIT, "STRLIT(\"%s\")")


	#define TOKENS \
		TOKENS_WITHOUT_FORMAT \
		TOKENS_WITH_FORMAT

    typedef enum {
	    OTHER,

	    #define TOKEN(NAME, STRING) \
	    	NAME,
		TOKENS
		#undef TOKEN
    } Token;

    Token lastToken = OTHER;

    void tokenPreHook(void);
    void nextLine(void);

    void checkLastToken(void);
    void printLastToken(void);
    void printLex(const char *token, const char *_string);
    void printLexF(const char *format, const char *string);
    void printToken(const Token token);

    typedef void (*PrintLexFunction)(const char *, const char *);

    #define ERROR_FORMAT(MESSAGE) "Line %d, column %d: " MESSAGE "\n"
    #define PRINT_ERROR(FORMAT, ...) printf(ERROR_FORMAT(FORMAT), __VA_ARGS__)
    #define YY_USER_ACTION tokenPreHook();
%}

digit			[0-9]
letter			[a-zA-Z_]
whitespace		[ \t]
lineterminator		"\n"|"\r\n"

SEMICOLON		";"
COMMA			","
BLANKID			"_"
ASSIGN			"="
STAR			"*"
DIV			"/"
MINUS			"-"
PLUS			"+"
EQ			"=="
GE			">="
GT			">"
LBRACE			"{"
LE			"<="
LPAR			"("
LSQ			"["
LT			"<"
MOD			"%"
NE			"!="
NOT			"!"
AND			"&&"
OR			"||"
RBRACE			"}"
RPAR			")"
RSQ			"]"
PACKAGE			"package"
RETURN			"return"
ELSE			"else"
FOR			"for"
IF			"if"
VAR			"var"
INT			"int"
FLOAT32			"float32"
BOOL			"bool"
STRING			"string"
PRINT			"fmt\.Println"
PARSEINT		"strconv\.Atoi"
FUNC			"func"
CMDARGS			"os\.Args"

RESERVED		(break|default|func|interface|select|case|defer|go|map|struct|chan|else|goto|package|switch|const|fallthrough|if|range|type|continue|for|import|return|var|\+\+|--)
NATURAL			(0|{HEXADECIMAL}|{OCTAL}|[1-9][0-9]*)
HEXADECIMAL		0[xX][0-9a-fA-F]+
OCTAL			0[0-7]+
DECIMAL			({digit}+[eE][+-]?{digit}+|({digit}*"."{digit}+|{digit}+"."{digit}*)([eE][+-]?{digit}+)?)
IDENTIFIER		({letter}|_)({letter}|{digit}|_)*
INVALID_OCTAL		0[0-7]*[8-9]+{digit}*

%X COMMENT
%X STR

%%
"/*"					{ BEGIN(COMMENT); stateLine = line; stateColumn = column - yyleng; }
<COMMENT>.				{ ; }
<COMMENT>\n				{ nextLine(); }
<COMMENT>"*/"				{ BEGIN(INITIAL); }
<COMMENT><<EOF>>			{ PRINT_ERROR("unterminated comment", stateLine, stateColumn); yyterminate(); }



\"				{
					BEGIN(STR);
					isValidString = true;
					stringDestroy(&string);
					stateLine = line;
					stateColumn = column - yyleng;
				}
<STR>\\[\\\"]			{ stringAppend(&string, yytext); }
<STR>\"				{
					stringAppend(&string, "");
					if (isValidString) {
						lastToken = STRLIT;
						printLastToken();
					}
					BEGIN(INITIAL);
				}
<STR>\n      			{
					PRINT_ERROR("unterminated string literal", stateLine, stateColumn);
					nextLine();
					stringAppend(&string, "");
					BEGIN(INITIAL);
				}
<STR>\\[^fnrt\\\"]		{
					const char escapeC = yytext[1];
					if (escapeC == '\n' || escapeC == '\r') {
						yytext[1] = '\0';
					}

					PRINT_ERROR("invalid escape sequence (%s)", line, column - yyleng, yytext);
					isValidString = false;

					if (escapeC == '\n') {
						PRINT_ERROR("unterminated string literal", stateLine, stateColumn);
						nextLine();
						stringAppend(&string, "");
						BEGIN(INITIAL);
					}
				}


<STR>.				{ stringAppend(&string, yytext); }
<STR><<EOF>>      		{
					PRINT_ERROR("unterminated string literal", stateLine, stateColumn);
					stringAppend(&string, "");
					yyterminate();
				}

{SEMICOLON}		{ lastToken = SEMICOLON; printLastToken(); }
{COMMA}			{ lastToken = COMMA; printLastToken(); }
{BLANKID}		{ lastToken = BLANKID; printLastToken(); }
{ASSIGN}		{ lastToken = ASSIGN; printLastToken(); }
{STAR}			{ lastToken = STAR; printLastToken(); }
{DIV}			{ lastToken = DIV; printLastToken(); }
{MINUS}			{ lastToken = MINUS; printLastToken(); }
{PLUS}			{ lastToken = PLUS; printLastToken(); }
{EQ}			{ lastToken = EQ; printLastToken(); }
{GE}			{ lastToken = GE; printLastToken(); }
{GT}			{ lastToken = GT; printLastToken(); }
{LBRACE}		{ lastToken = LBRACE; printLastToken(); }
{LE}			{ lastToken = LE; printLastToken(); }
{LPAR}			{ lastToken = LPAR; printLastToken(); }
{LSQ}			{ lastToken = LSQ; printLastToken(); }
{LT}			{ lastToken = LT; printLastToken(); }
{MOD}			{ lastToken = MOD; printLastToken(); }
{NE}			{ lastToken = NE; printLastToken(); }
{NOT}			{ lastToken = NOT; printLastToken(); }
{AND}			{ lastToken = AND; printLastToken(); }
{OR}			{ lastToken = OR; printLastToken(); }
{RBRACE}		{ lastToken = RBRACE; printLastToken(); }
{RPAR}			{ lastToken = RPAR; printLastToken(); }
{RSQ}			{ lastToken = RSQ; printLastToken(); }
{PACKAGE}		{ lastToken = PACKAGE; printLastToken(); }
{RETURN}		{ lastToken = RETURN; printLastToken(); }
{ELSE}			{ lastToken = ELSE; printLastToken(); }
{FOR}			{ lastToken = FOR; printLastToken(); }
{IF}			{ lastToken = IF; printLastToken(); }
{VAR}			{ lastToken = VAR; printLastToken(); }
{INT}			{ lastToken = INT; printLastToken(); }
{FLOAT32}		{ lastToken = FLOAT32; printLastToken(); }
{BOOL}			{ lastToken = BOOL; printLastToken(); }
{STRING}		{ lastToken = STRING; printLastToken(); }
{PRINT}			{ lastToken = PRINT; printLastToken(); }
{PARSEINT}		{ lastToken = PARSEINT; printLastToken(); }
{FUNC}			{ lastToken = FUNC; printLastToken(); }
{CMDARGS}		{ lastToken = CMDARGS; printLastToken(); }

{RESERVED}		{ lastToken = RESERVED; printLastToken(); }
{NATURAL}		{ lastToken = NATURAL; printLastToken(); }
{DECIMAL}		{ lastToken = DECIMAL; printLastToken(); }
{IDENTIFIER}		{ lastToken = IDENTIFIER; printLastToken(); }

{lineterminator}	{
				nextLine();

				checkLastToken();
				lastToken = OTHER;
			}
({whitespace}+|"//".*)	{;}
{INVALID_OCTAL}		{ PRINT_ERROR("invalid octal constant (%s)", line, column - yyleng, yytext); }
.			{ PRINT_ERROR("illegal character (%s)", line, column - yyleng, yytext); }
<<EOF>>			{
				checkLastToken();
				lastToken = OTHER;
				yyterminate();
			}

%%
int yywrap() {  /* called on EOF, return 1 to terminate */
    return 1;
}

void tokenPreHook() { /* called before every catched token */
	column += yyleng;
}

void nextLine(void) {
	++line;
	column = 1;
}

void printLex(const char *token, const char *_string) {
	(void) _string;

	if (token == NULL) {
		return;
	}

	printf("%s\n", token);
}

void printLexF(const char *format, const char *string) {
	if (format == NULL || *format == '\0' || string == NULL || *string == '\0') {
		return;
	}

	printf(format, string);
	printf("\n");
}

void printToken(const Token token) {
	if (!(debugMode & Lexer)) {
		return;
	}

	// HACK: Fix
	if (token == STRLIT) {
		printf("STRLIT(\"%s\")\n", string.buffer);
		return;
	}

	char *format = NULL;
	char *string = NULL;

	PrintLexFunction printF = NULL;
	switch (token) {
#define TOKEN(NAME, STRING) \
		case NAME: \
			   format = STRING; \
		printF = printLex; \
		break;
		TOKENS_WITHOUT_FORMAT
#undef TOKEN
#define TOKEN(NAME, FORMAT) \
		case NAME: \
			   format = FORMAT; \
			string = yytext; \
			printF = printLexF; \
			break;
			TOKENS_WITH_FORMAT
#undef TOKEN
		default:
			printf("Invalid Token\n");
			break;
	}

	printF(format, string);
}

void printLastToken(void) {
	printToken(lastToken);
}

inline void checkLastToken(void) {
	switch (lastToken) {
		case NATURAL:
		case DECIMAL:
		case STRLIT:
		case IDENTIFIER:
		case RETURN:
		case RPAR:
		case RSQ:
		case RBRACE:
			printToken(SEMICOLON);
			break;
		default:
			break;
	}
}

void stringAppend(String *dest, const char *src) {
	if (dest == NULL || src == NULL) {
		return;
	}

	const size_t srcLength = strlen(src);

	if (dest->length + srcLength + 1 > dest->capacity) {
		if (dest->capacity == 0) {
			dest->capacity = 1;
		}

		while (dest->length + srcLength + 1 > dest->capacity) {
			dest->capacity *= 2;
		}

		const bool clean = dest->buffer == NULL;
		dest->buffer =
			realloc(dest->buffer, dest->capacity * sizeof(dest->buffer[0]));

		if (clean) {
			*dest->buffer = '\0';
		}
	}

	strcat(dest->buffer, src);
	dest->length += srcLength;
}

void stringDestroy(String *string) {
  if (string == NULL) {
    return;
  }

  if (string->buffer != NULL) {
	  free(string->buffer);
  }
  *string = (String){0};
}
