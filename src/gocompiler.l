%{
    #include <ctype.h>

    int line = 1;
    int column = 1;

    void tokenPreHook(void);

    char* toUpperString(char *temp) {
	    char *name;
	    name = strtok(temp,":");

	    // Convert to upper case
	    char *s = name;
	    while (*s) {
		    *s = toupper((unsigned char) *s);
		    s++;
	    }

	    return temp;

    }

    #define YY_USER_ACTION tokenPreHook();
%}
digit   [0-9]
letter	[a-zA-Z_]
keywords (break|default|func|interface|select|case|defer|go|map|struct|chan|else|goto|package|switch|const|fallthrough|if|range|type|continue|for|import|return|var|\+\+|--)
whitespace [ \t]
%X COMMENT
%X STRING
%%
"/*"					{ BEGIN(COMMENT); }
<COMMENT>.				{ ECHO; }
<COMMENT>\n				{ ++line; column = 1; ECHO; }
<COMMENT>"*/"				{ BEGIN(INITIAL); }
\"					{ BEGIN(STRING); printf("STRLIT(\""); }
<STRING>.				{ ECHO; }
<STRING>[^\\]\"				{ ECHO; printf(")\n"); BEGIN(INITIAL); }
";"					{ printf("SEMICOLON\n"); }
","					{ printf("COMMA\n"); }
"_"					{ printf("BLANKID\n"); }
"="					{ printf("ASSIGN\n"); }
"*"					{ printf("STAR\n"); }
"/"					{ printf("DIV\n"); }
"-"					{ printf("MINUS\n"); }
"+"					{ printf("PLUS\n"); }
"=="					{ printf("EQ\n"); }
">="					{ printf("GE\n"); }
">"					{ printf("GT\n"); }
"{"					{ printf("LBRACE\n"); }
"<="					{ printf("LE\n"); }
"("					{ printf("LPAR\n"); }
"["					{ printf("LSQ\n"); }
"<"					{ printf("LT\n"); }
"%"					{ printf("MOD\n"); }
"!="					{ printf("NE\n"); }
"!"					{ printf("NOT\n"); }
"&&"					{ printf("AND\n"); }
"||"					{ printf("OR\n"); }
"}"					{ printf("RBRACE\n"); }
")"					{ printf("RPAR\n"); }
"]"					{ printf("RSQ\n"); }
package					{ printf("PACKAGE\n"); }
return					{ printf("RETURN\n"); }
else					{ printf("ELSE\n"); }
for					{ printf("FOR\n"); }
if					{ printf("IF\n"); }
var					{ printf("VAR\n"); }
int					{ printf("INT\n"); }
float32					{ printf("FLOAT32\n"); }
bool					{ printf("BOOL\n"); }
string					{ printf("STRING\n"); }
fmt\.Println				{ printf("PRINT\n"); }
strconv.Atoi				{ printf("PARSEINT\n"); }
func					{ printf("FUNC\n"); }
os\.Args				{ printf("CMDARGS\n"); }
{keywords}				{ printf("RESERVED(%s)\n", yytext); }
(0[xX][0-9a-fA-F]+|0[0-7]*|[1-9][0-9]*)	{ printf("NATURAL(%s)\n", yytext); }
{digit}+e[+-]?{digit}+			{ printf("DECIMAL(%s)\n", yytext); /* TODO: Merge this rule into rule below */ }
({digit}*"."{digit}+|{digit}+"."{digit}*)(e[+-]?{digit}+)?  	{ printf("DECIMAL(%s)\n", yytext); }
({letter}|_)({letter}|{digit}|_)*	{ printf("IDENTIFIER(%s)\n", yytext); }
\n					{ ++line; column = 1; }
({whitespace}+|"//".*)			{;}
.					{ printf("Line %d, column %d: illegal character (%s)\n", line, column - yyleng, yytext); }

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
