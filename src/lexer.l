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
keywords (break|default|func|interface|select|case|defer|go|map|struct|chan|else|goto|package|switch|const|fallthrough|if|range|type|continue|for|import|return|var)
whitespace [ \t]
%X COMMENT
%X STRING
%%
"/*"			{ BEGIN(COMMENT); }
<COMMENT>.		{ ECHO; }
<COMMENT>\n		{ ++line; column = 1; ECHO; }
<COMMENT>"*/"		{ BEGIN(INITIAL); }
\"			{ BEGIN(STRING); printf("STRLIT(\""); }
<STRING>.		{ ECHO; }
<STRING>[^\\]\"		{ ECHO; printf(")\n"); BEGIN(INITIAL); }
{keywords}		{ printf("%s\n", toUpperString(yytext)); }
{digit}+                { printf("NATURAL(%s)\n", yytext); }
{digit}*"."{digit}+     { printf("DECIMAL(%s)\n", yytext); }
{letter}({letter}|{digit})*		{ printf("IDENTIFIER(%s)\n", yytext); }
\n			{ ++line; column = 1; }
{whitespace}+		{;}
.			{ printf("Line %d, column %d: illegal character (%s)\n", line, column - yyleng, yytext); }

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
