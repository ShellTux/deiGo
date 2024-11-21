#include "gocompiler.h"
#include "parser.h"

#include "y.tab.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum DebugMode debugMode = None;
struct Node *program = NULL;
struct Errors errors = {0};

void usage(const char *const programName) {
  if (programName == NULL) {
    exit(EXIT_FAILURE);
  }

  fprintf(stderr, "Usage: %s\n", programName);
  exit(EXIT_FAILURE);
}

int main(int argc, char **argv) {
  for (int i = 1; i < argc; ++i) {
    const char *arg = argv[i];

    if (strcmp("-h", arg) == 0 || strcmp("--help", arg) == 0) {
      usage(argv[0]);
    }

    debugMode |= Lexer * ((strcmp("-l", arg) == 0) ? 1 : 0);
    debugMode |= Parser * ((strcmp("-t", arg) == 0) ? 1 : 0);
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

  printNode(program, 0);
#else
#ifdef DEBUG
  yydebug = 1;
#endif
  yyparse();

  if ((debugMode & Parser) && errors.lexer + errors.syntax <= 0) {
    printNode(program, 0);
  }
#endif
  return 0;
}
