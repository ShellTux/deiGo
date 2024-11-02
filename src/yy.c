#include "yy.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

DebugMode debugMode = None;
int line = 1;
int column = 1;
int stateLine;
int stateColumn;

extern int yylex();

void yyerror(const char *string) { (void)string; }

void usage(const char *programName) {
  printf("Usage: %s TODO\n", programName);
  exit(EXIT_FAILURE);
}

int main(int argc, char **argv) {
  for (int i = 1; i < argc; ++i) {
    const char *arg = argv[i];

    if (strcmp("-h", arg) == 0 || strcmp("--help", arg) == 0) {
      usage(argv[0]);
    }

    debugMode |= Lexer * (strcmp("-l", arg) == 0);
    debugMode |= Parser * (strcmp("-t", arg) == 0);
  }

  yylex();
  return 0;
}
