#include "codegen.h"
#include "gocompiler.h"
#include "parser.h"
#include "semantics.h"

#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum DebugMode debugMode = None;
struct Node *program = NULL;
struct Errors errors = {0};
extern struct SymbolList *globalSymbolTable;

int main(int argc, char **argv) {
  for (int i = 1; i < argc; ++i) {
    const char *arg = argv[i];

    if (strcmp("-h", arg) == 0 || strcmp("--help", arg) == 0) {
      fprintf(stderr, "Usage: %s [options]\n", argv[0]);
      fprintf(stderr, "Options:\n");
      fprintf(stderr, "  -h, --help\t    Print this usage information\n");
#define DEBUG_MODE(ENUM, VALUE, SHORT_OPTION, LONG_OPTION, DESCRIPTION)        \
  if (ENUM != None)                                                            \
    fprintf(stderr,                                                            \
            "  " SHORT_OPTION ", " LONG_OPTION "\t    " DESCRIPTION "\n");
      DEBUG_MODES
#undef DEBUG_MODE
      exit(EXIT_FAILURE);
    }

#define DEBUG_MODE(ENUM, VALUE, SHORT_OPTION, LONG_OPTION, DESCRIPTION)        \
  debugMode |=                                                                 \
      ENUM * (strcmp(SHORT_OPTION, arg) == 0 || strcmp(LONG_OPTION, arg) == 0  \
                  ? 1                                                          \
                  : 0);
    DEBUG_MODES
#undef DEBUG_MODE
  }

#ifdef AST_DEMO
  program = createNode(Program, NULL);
  {
    struct Node *function1 = addChild(program, createNode(FuncDecl, NULL));
    {
      struct Node *funcHeader =
          addChild(function1, createNode(FuncHeader, NULL));
      {
        addChild(funcHeader, createNode(Identifier, "factorial"));
        addChild(funcHeader, createNode(Int, NULL));
        struct Node *funcParams =
            addChild(funcHeader, createNode(FuncParams, NULL));
        {
          struct Node *paramDecl =
              addChild(funcParams, createNode(ParamDecl, NULL));
          {
            addChild(paramDecl, createNode(Int, NULL));
            addChild(paramDecl, createNode(Identifier, "n"));
          }
        }
      }

      struct Node *funcBody = addChild(function1, createNode(FuncBody, NULL));
      {
        struct Node *ifNode = addChild(funcBody, createNode(If, NULL));
        {
          struct Node *eq = addChild(ifNode, createNode(Eq, NULL));
          {
            addChild(eq, createNode(Identifier, "n"));
            addChild(eq, createNode(Natural, "0"));
          }

          struct Node *block1 = addChild(ifNode, createNode(Block, NULL));
          {
            struct Node *returnNode =
                addChild(block1, createNode(Return, NULL));
            {
              addChild(returnNode, createNode(Natural, "1"));
            }
          }

          addChild(ifNode, createNode(Block, NULL));
        }

        struct Node *returnNode = addChild(funcBody, createNode(Return, NULL));
        {
          struct Node *mul = addChild(returnNode, createNode(Mul, NULL));
          {
            addChild(mul, createNode(Identifier, "n"));
            struct Node *call = addChild(mul, createNode(Call, NULL));
            {
              addChild(call, createNode(Identifier, "factorial"));
              struct Node *sub = addChild(call, createNode(Sub, NULL));
              {
                addChild(sub, createNode(Identifier, "n"));
                addChild(sub, createNode(Natural, "1"));
              }
            }
          }
        }
      }
    }

    struct Node *function2 = addChild(program, createNode(FuncDecl, NULL));
    {
      struct Node *funcHeader =
          addChild(function2, createNode(FuncHeader, NULL));
      {
        addChild(funcHeader, createNode(Identifier, "main"));
        addChild(funcHeader, createNode(FuncParams, NULL));
      }

      struct Node *funcBody = addChild(function2, createNode(FuncBody, NULL));
      {
        struct Node *varDecl = addChild(funcBody, createNode(VarDecl, NULL));
        {
          addChild(varDecl, createNode(Int, NULL));
          addChild(varDecl, createNode(Identifier, "argument"));
        }

        struct Node *parseArgs =
            addChild(funcBody, createNode(ParseArgs, NULL));
        {
          addChild(parseArgs, createNode(Identifier, "argument"));
          addChild(parseArgs, createNode(Natural, "1"));
        }

        struct Node *print = addChild(funcBody, createNode(Print, NULL));
        {
          struct Node *call = addChild(print, createNode(Call, NULL));
          {
            addChild(call, createNode(Identifier, "factorial"));
            addChild(call, createNode(Identifier, "argument"));
          }
        }
      }
    }
  }
#else
#ifdef DEBUG
  yydebug = 1;
#endif
  yyparse();
#endif

  if (errors.lexer + errors.syntax > 0) {
    return 1;
  }

  if (debugMode & Parser) {
    showSymbolTable(globalSymbolTable);
    printNode(program, 0);
    return 0;
  }

  if (debugMode & Semantic) {
    if (checkProgram(program) > 0) {
      return 1;
    }

    showSymbolTable(globalSymbolTable);
    printNode(program, 0);
    return 0;
  }

  if (checkProgram(program) > 0) {
    return 1;
  }

  codegen_program(program);

  return 0;
}
