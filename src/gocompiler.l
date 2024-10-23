/* Luís Pedro de Sousa Oliveira Góis 2018280716 */
/* João Fonseca 2021227194 */
%{
    #include <ctype.h>

    int line = 1;
    int column = 1;

    int stateLine;
    int stateColumn;

    char buf[4096];
    char *string = NULL;

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
	    TOKEN(RESERVED, "RESERVED") \
	    TOKEN(NATURAL, "NATURAL") \
	    TOKEN(DECIMAL, "DECIMAL") \
	    TOKEN(IDENTIFIER, "IDENTIFIER") \
	    TOKEN(STRLIT, "STRLIT")


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

    void printLex(const char *token) {
    	if (token == NULL) {
		return;
	}

    	printf("%s\n", token);
    }

    void printLexF(const char *token) {
    	if (token == NULL) {
		return;
	}

	printf("%s(%s)\n", token, yytext);
    }

    typedef void (*PrintLexFunction)(const char *);

    void printToken(const Token token) {
	char *string = NULL;
	PrintLexFunction printF = NULL;
	switch (token) {
		#define TOKEN(NAME, STRING) \
			case NAME: \
				string = STRING; \
				printF = printLex; \
				break;
		TOKENS_WITHOUT_FORMAT
		#undef TOKEN
		#define TOKEN(NAME, STRING) \
			case NAME: \
				string = STRING; \
				printF = printLexF; \
				break;
		TOKENS_WITH_FORMAT
		#undef TOKEN
		default:
			printf("Invalid Token\n");
			break;
	}

	printF(string);
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
NATURAL			(0[xX][0-9a-fA-F]+|0[0-7]*|[1-9][0-9]*)
DECIMAL			({digit}+e[+-]?{digit}+|({digit}*"."{digit}+|{digit}+"."{digit}*)(e[+-]?{digit}+)?)
IDENTIFIER		({letter}|_)({letter}|{digit}|_)*

%X COMMENT
%X STR
%X INVALID_STR

%%
"/*"					{ BEGIN(COMMENT); stateLine = line; stateColumn = column - yyleng; }
<COMMENT>.				{ ; }
<COMMENT>\n				{ ++line; column = 1; }
<COMMENT>"*/"				{ BEGIN(INITIAL); }
<COMMENT><<EOF>>			{ PRINT_ERROR("unterminated comment", stateLine, stateColumn); yyterminate(); }



\"				{
					BEGIN(STR);
					string = buf;
					stateLine = line;
					stateColumn = column - yyleng;
				}
<STR>\\\"			{ *string++ = '\\'; *string++ = '\"'; }
<STR>\\\\			{ *string++ = '\\'; *string++ = '\\'; }
<STR>\"				{
					*string = '\0';
					lastToken = STRLIT;
					printf("STRLIT(\"%s\")\n", buf);
					BEGIN(INITIAL);
				}
<STR>\n      			{
					PRINT_ERROR("unterminated string literal", stateLine,stateColumn);
					column = 1;
					++line;
					*string = '\0';
					BEGIN(INITIAL);
				}
<STR>\\[^fnrt\\\"]		{
					PRINT_ERROR("invalid escape sequence (%s)", line, column - yyleng, yytext);
					BEGIN(INVALID_STR);
				}


<STR>.				{ *string++ = *yytext; }
<STR><<EOF>>      		{
					PRINT_ERROR("unterminated string literal", stateLine, stateColumn);
					*string = '\0';
					yyterminate();
				}

<INVALID_STR>\\[^fnrt\\\"]	{ PRINT_ERROR("invalid escape sequence (%s)", line, column - yyleng, yytext); }
<INVALID_STR>\\			{ *string++ = '\\'; }
<INVALID_STR>\"			{ *string = '\0'; BEGIN(INITIAL); }
<INVALID_STR>.			{ *string++ = *yytext; }
<INVALID_STR>\n			{
					PRINT_ERROR("unterminated string literal", stateLine,stateColumn);
					column = 1;
					++line;
					*string = '\0';
					BEGIN(INITIAL);
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
				++line;
				column = 1;

				checkLastToken();
				lastToken = OTHER;
			}
({whitespace}+|"//".*)	{;}
0[089][0-9]*		{ PRINT_ERROR("invalid octal constant (%s)", line, column - yyleng, yytext); }
.			{ PRINT_ERROR("illegal character (%s)", line, column - yyleng, yytext); }
<<EOF>>			{
				checkLastToken();
				lastToken = OTHER;
				yyterminate();
			}

%%

extern int yylex();
int main() {
    yylex();    /* run the lexical analysis automaton */
    return 0;
}
int yywrap() {  /* called on EOF, return 1 to terminate */
    return 1;
}
void tokenPreHook() { /* called before every catched token */
	column += yyleng;
}
