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

    #include "gocompiler.h"
    #include "lexer.h"
    #include "y.tab.h"

    extern bool isValidString;
    extern enum DebugMode debugMode;
    extern struct Errors errors;
    extern LexerToken lastToken;
    extern struct String string;

    extern struct Pos lexerPos;
    extern struct Pos statePos;
    extern struct Pos syntaxPos;

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
PRINT			"fmt.Println"
PARSEINT		"strconv.Atoi"
FUNC			"func"
CMDARGS			"os.Args"

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
"/*"					{
						BEGIN(COMMENT);

						statePos = (struct Pos){
							.line = lexerPos.line,
							.column = lexerPos.column - yyleng,
						};
					}
<COMMENT>.				{ ; }
<COMMENT>\n				{ nextLine(); }
<COMMENT>"*/"				{ BEGIN(INITIAL); }
<COMMENT><<EOF>>			{ PRINT_ERROR("unterminated comment", statePos.line, statePos.column); yyterminate(); }



\"				{
					BEGIN(STR);
					isValidString = true;
					stringDestroy(&string);
					statePos = (struct Pos){
						.line = lexerPos.line,
						.column = lexerPos.column - yyleng,
					};
				}
<STR>\\[\\\"]			{ stringAppend(&string, yytext); }
<STR>\"				{
					stringAppend(&string, "");
					if (isValidString) {
						lastToken = L_STRLIT;
						printLastToken();
					}
					BEGIN(INITIAL);

					if (isValidString && !(debugMode & Lexer)) {
                                                yylval.string = strdup(string.buffer);
						return STRLIT;
					}
				}
<STR>\n      			{
					PRINT_ERROR("unterminated string literal", statePos.line, statePos.column);
					nextLine();
					stringAppend(&string, "");
					BEGIN(INITIAL);
				}
<STR>\\[^fnrt\\\"]		{
					const char escapeC = yytext[1];
					if (escapeC == '\n' || escapeC == '\r') {
						yytext[1] = '\0';
					}

					PRINT_ERROR("invalid escape sequence (%s)", lexerPos.line, lexerPos.column - yyleng, yytext);
					isValidString = false;

					if (escapeC == '\n') {
						PRINT_ERROR("unterminated string literal", statePos.line, statePos.column);
						nextLine();
						stringAppend(&string, "");
						BEGIN(INITIAL);
					}
				}


<STR>.				{ stringAppend(&string, yytext); }
<STR><<EOF>>      		{
					PRINT_ERROR("unterminated string literal", statePos.line, statePos.column);
					stringAppend(&string, "");
					yyterminate();
				}

{SEMICOLON}		{ lastToken = L_SEMICOLON;   printLastToken(); if (!(debugMode & Lexer)) return SEMICOLON; }
{COMMA}			{ lastToken = L_COMMA;       printLastToken(); if (!(debugMode & Lexer)) return COMMA;     }
{BLANKID}		{ lastToken = L_BLANKID;     printLastToken(); if (!(debugMode & Lexer)) return BLANKID;   }
{ASSIGN}		{ lastToken = L_ASSIGN;      printLastToken(); if (!(debugMode & Lexer)) return ASSIGN;    }
{STAR}			{ lastToken = L_STAR;        printLastToken(); if (!(debugMode & Lexer)) return STAR;      }
{DIV}			{ lastToken = L_DIV;         printLastToken(); if (!(debugMode & Lexer)) return DIV;       }
{MINUS}			{ lastToken = L_MINUS;       printLastToken(); if (!(debugMode & Lexer)) return MINUS;     }
{PLUS}			{ lastToken = L_PLUS;        printLastToken(); if (!(debugMode & Lexer)) return PLUS;      }
{EQ}			{ lastToken = L_EQ;          printLastToken(); if (!(debugMode & Lexer)) return EQ;        }
{GE}			{ lastToken = L_GE;          printLastToken(); if (!(debugMode & Lexer)) return GE;        }
{GT}			{ lastToken = L_GT;          printLastToken(); if (!(debugMode & Lexer)) return GT;        }
{LBRACE}		{ lastToken = L_LBRACE;      printLastToken(); if (!(debugMode & Lexer)) return LBRACE;    }
{LE}			{ lastToken = L_LE;          printLastToken(); if (!(debugMode & Lexer)) return LE;        }
{LPAR}			{ lastToken = L_LPAR;        printLastToken(); if (!(debugMode & Lexer)) return LPAR;      }
{LSQ}			{ lastToken = L_LSQ;         printLastToken(); if (!(debugMode & Lexer)) return LSQ;       }
{LT}			{ lastToken = L_LT;          printLastToken(); if (!(debugMode & Lexer)) return LT;        }
{MOD}			{ lastToken = L_MOD;         printLastToken(); if (!(debugMode & Lexer)) return MOD;       }
{NE}			{ lastToken = L_NE;          printLastToken(); if (!(debugMode & Lexer)) return NE;        }
{NOT}			{ lastToken = L_NOT;         printLastToken(); if (!(debugMode & Lexer)) return NOT;       }
{AND}			{ lastToken = L_AND;         printLastToken(); if (!(debugMode & Lexer)) return AND;       }
{OR}			{ lastToken = L_OR;          printLastToken(); if (!(debugMode & Lexer)) return OR;        }
{RBRACE}		{ lastToken = L_RBRACE;      printLastToken(); if (!(debugMode & Lexer)) return RBRACE;    }
{RPAR}			{ lastToken = L_RPAR;        printLastToken(); if (!(debugMode & Lexer)) return RPAR;      }
{RSQ}			{ lastToken = L_RSQ;         printLastToken(); if (!(debugMode & Lexer)) return RSQ;       }
{PACKAGE}		{ lastToken = L_PACKAGE;     printLastToken(); if (!(debugMode & Lexer)) return PACKAGE;   }
{RETURN}		{ lastToken = L_RETURN;      printLastToken(); if (!(debugMode & Lexer)) return RETURN;    }
{ELSE}			{ lastToken = L_ELSE;        printLastToken(); if (!(debugMode & Lexer)) return ELSE;      }
{FOR}			{ lastToken = L_FOR;         printLastToken(); if (!(debugMode & Lexer)) return FOR;       }
{IF}			{ lastToken = L_IF;          printLastToken(); if (!(debugMode & Lexer)) return IF;        }
{VAR}			{ lastToken = L_VAR;         printLastToken(); if (!(debugMode & Lexer)) return VAR;       }
{INT}			{ lastToken = L_INT;         printLastToken(); if (!(debugMode & Lexer)) return INT;       }
{FLOAT32}		{ lastToken = L_FLOAT32;     printLastToken(); if (!(debugMode & Lexer)) return FLOAT32;   }
{BOOL}			{ lastToken = L_BOOL;        printLastToken(); if (!(debugMode & Lexer)) return BOOL;      }
{STRING}		{ lastToken = L_STRING;      printLastToken(); if (!(debugMode & Lexer)) return STRING;    }
{PRINT}			{ lastToken = L_PRINT;       printLastToken(); if (!(debugMode & Lexer)) return PRINT;     }
{PARSEINT}		{ lastToken = L_PARSEINT;    printLastToken(); if (!(debugMode & Lexer)) return PARSEINT;  }
{FUNC}			{ lastToken = L_FUNC;        printLastToken(); if (!(debugMode & Lexer)) return FUNC;      }
{CMDARGS}		{ lastToken = L_CMDARGS;     printLastToken(); if (!(debugMode & Lexer)) return CMDARGS;   }

{RESERVED}		{ lastToken = L_RESERVED;    printLastToken(); if (!(debugMode & Lexer)) return RESERVED;  }
{NATURAL}		{ lastToken = L_NATURAL;     printLastToken(); if (!(debugMode & Lexer)) { yylval.string = strdup(yytext); return NATURAL; } }
{DECIMAL}		{ lastToken = L_DECIMAL;     printLastToken(); if (!(debugMode & Lexer)) { yylval.string = strdup(yytext); return DECIMAL; } }
{IDENTIFIER}		{ lastToken = L_IDENTIFIER;  printLastToken(); if (!(debugMode & Lexer)) { yylval.string = strdup(yytext); return IDENTIFIER; } }

{lineterminator}	{
				nextLine();

				if (checkLastToken() && !(debugMode & Lexer)) {
					lastToken = L_OTHER;
					return SEMICOLON;
				}

				lastToken = L_OTHER;
			}
({whitespace}+|"//".*)	{;}
{INVALID_OCTAL}		{ PRINT_ERROR("invalid octal constant (%s)", lexerPos.line, lexerPos.column - yyleng, yytext); }
.			{ PRINT_ERROR("illegal character (%s)", lexerPos.line, lexerPos.column - yyleng, yytext); }
<<EOF>>			{
				if (checkLastToken() && !(debugMode & Lexer)) {
					lastToken = L_OTHER;
					return SEMICOLON;
				}
				lastToken = L_OTHER;
				yyterminate();
			}

%%
int yywrap() {  /* called on EOF, return 1 to terminate */
    return 1;
}

void tokenPreHook() { /* called before every catched token */
  syntaxPos = lexerPos;

  lexerPos.column += yyleng;
}

void nextLine(void) {
  lexerPos.line++;
  lexerPos.column = 1;
}

void yyerror(const char *error) {
	errors.lexer++;

	if (!(debugMode & Parser) && strcmp("syntax error", error) == 0) {
		errors.syntax++;
		return;
	}

	printf(ERROR_FORMAT("%s: %s"), syntaxPos.line, syntaxPos.column, error, yytext);
}
// vim: expandtab:shiftwidth=4:softtabstop=4:smartindent
