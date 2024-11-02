#ifndef INCLUDE_INCLUDE_YY_H_
#define INCLUDE_INCLUDE_YY_H_

#include <stdbool.h>

void yyerror(const char *);
void usage(const char *programName);

typedef enum {
  None = 0,
  Lexer = 1 << 0,
  Parser = 1 << 1,
} DebugMode;

extern DebugMode debugMode;
extern int line;
extern int column;
extern int stateLine;
extern int stateColumn;

#endif // INCLUDE_INCLUDE_YY_H_
