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
#include "semantics.h"
#include "debug.h"
#include "gocompiler.h"
#include "parser.h"

#include <assert.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define STRING_MAX 4096
static char tempString[STRING_MAX + 1] = "";

struct SymbolList *globalSymbolTable = NULL;

extern struct Errors errors;
extern FILE *outFile;

void printSymbolList(const struct SymbolList *symbolList, const int depth) {
  if (symbolList == NULL) {
    return;
  }

#define PRINT_IDENTATION                                                       \
  for (int i = 0; i < depth; ++i) {                                            \
    fprintf(outFile, "  ");                                                    \
  }

  PRINT_IDENTATION;

  fprintf(outFile,
          "{identifier: %s, type: %s, node: %p, next: %p, scope: %p}\n",
          symbolList->identifier, identifierTypeS(symbolList->type),
          symbolList->node, symbolList->next, symbolList->scope);

  /*printSymbolList(symbolList->scope, depth);*/

  printSymbolList(symbolList->next, depth + 1);

#undef PRINT_IDENTATION
}

struct SymbolList *insertSymbol(struct SymbolList *table,
                                const char *identifier,
                                const enum IdentifierType type,
                                const struct Node *node) {
  struct SymbolList *new = NULL;

  for (struct SymbolList *symbol = table; symbol != NULL;
       symbol = symbol->next) {
    if (symbol->next != NULL) {
      if (strcmp(symbol->next->identifier, identifier) == 0) {
        return NULL;
      }

      continue;
    }

    new = malloc(sizeof(*new));
    *new = (struct SymbolList){
        .identifier = strdup(identifier),
        .type = type,
        .next = NULL,
        .node = (struct Node *)node,
        .scope = NULL,
    };

    symbol->next = new;
    break;
  }

  return new;
}

struct SymbolList *searchSymbol(const struct SymbolList *list,
                                const char *const identifier) {
  for (struct SymbolList *symbol = (struct SymbolList *)list; symbol != NULL;
       symbol = symbol->next) {

    if (strcmp(identifier, symbol->identifier) != 0) {
      continue;
    }

    return symbol;
  }

  return NULL;
}

char *getParamsS(const struct Node *node) {
  if (node == NULL) {
    return "";
  }

  *tempString = '\0';

  const struct Node *funcHeader = getChild(node, 0);
  const struct Node *parameters = getChild(funcHeader, 1);
  assert(parameters != NULL && "parameters == NULL");
  if (parameters->tokenType != FuncParams) {
    parameters = getChild(funcHeader, 2);
  }

  for (struct NodeList *children = parameters->children; children != NULL;
       children = children->next) {
    strcat(tempString, identifierTypeS(children->node->identifierType));

    if (children->next != NULL) {
      strcat(tempString, ",");
    }
  }

  return tempString;
}

bool isParam(const struct Node *param, const struct Node *function) {
  if (param == NULL || function == NULL) {
    return false;
  }

  struct Node *header = getChild(function, 0);
  struct Node *params = getChild(header, 1);

  if (params != NULL && params->tokenType != FuncParams) {
    params = getChild(header, 2);
  }

  for (struct NodeList *child = params->children; child != NULL;
       child = child->next) {
    if (child->node == param) {
      return true;
    }
  }

  return false;
}

void showSymbolTable(struct SymbolList *symbolTable) {
  if (symbolTable == NULL) {
    return;
  }

  fprintf(outFile, "===== Global Symbol Table =====\n");

  for (struct SymbolList *symbol = symbolTable->next; symbol != NULL;
       symbol = symbol->next) {
    fprintf(outFile, "%s\t(%s)\t%s\n", symbol->identifier,
            getParamsS(symbol->node), identifierTypeS(symbol->type));
  }

  fprintf(outFile, "\n");

  for (struct SymbolList *symbol = symbolTable->next; symbol != NULL;
       symbol = symbol->next) {
    const struct Node *node = symbol->node;
    switch (node->tokenType) {
    case VarDecl: {
      showSymbolTableVarDecl(symbol);
    } break;
    case FuncDecl: {
      showSymbolTableFuncDecl(symbol);
    } break;
    default:
      break;
    }
  }
}

void showSymbolTableFuncDecl(struct SymbolList *symbolTable) {
  if (symbolTable == NULL) {
    return;
  }

  const struct Node *node = symbolTable->node;

  if (node == NULL || node->tokenType != FuncDecl) {
    DEBUG_PRINT("node->tokenType = %s", categoryS(node->tokenType));
    return;
  }

  fprintf(outFile, "===== Function %s(%s) Symbol Table =====\n",
          symbolTable->identifier, getParamsS(symbolTable->node));
  fprintf(outFile, "return\t\t%s\n", identifierTypeS(symbolTable->type));

  for (struct SymbolList *scope = symbolTable->scope->next; scope != NULL;
       scope = scope->next) {
    fprintf(outFile, "%s\t\t%s%s\n", scope->identifier,
            identifierTypeS(scope->type),
            isParam(scope->node, node) ? "\tparam" : "");
  }

  fprintf(outFile, "\n");
}

void showSymbolTableVarDecl(struct SymbolList *symbolTable) {
  if (symbolTable == NULL) {
    return;
  }

  for (struct SymbolList *symbol = symbolTable; symbol != NULL;
       symbol = symbol->next) {
    const struct Node *node = symbol->node;
    if (node == NULL) {
      continue;
    }

    fprintf(outFile, "%s\t\t%s%s\n", node->tokenValue,
            identifierTypeS(node->identifierType),
            isParam(NULL, NULL) ? "\tparam" : "");
  }
}

int checkProgram(struct Node *program) {
  int semanticErrors = 0;

  if (program == NULL) {
    return semanticErrors;
  }

  if (globalSymbolTable == NULL) {
    globalSymbolTable = malloc(sizeof(*globalSymbolTable));
    *globalSymbolTable = (struct SymbolList){0};
  }

  for (struct NodeList *child = program->children; child != NULL;
       child = child->next) {

    struct Node *node = child->node;
    switch (node->tokenType) {
    case VarDecl: {
      semanticErrors += checkVarDecl(globalSymbolTable, node);
    } break;
    case FuncDecl: {
      semanticErrors += checkFuncDecl(globalSymbolTable, node);
    } break;
    default:
      break;
    }
  }

  return semanticErrors;
}

int checkVarDecl(struct SymbolList *scope, struct Node *varDecl) {
  assert(scope != NULL && "Scope == NULL");
  assert(varDecl != NULL && "Scope == NULL");

  struct Node *id = getChild(varDecl, 1);
  enum IdentifierType type =
      Category2IdentifierType(getChild(varDecl, 0)->tokenType);
  if (insertSymbol(scope, id->tokenValue, type, varDecl) == NULL) {
    errorSymbol(SYMBOL_ALREADY_DEFINED_ERROR, id);
    return 1;
  }

  return 0;
}

int checkFuncDecl(struct SymbolList *symbolTable, struct Node *function) {
  assert(symbolTable != NULL && "symbolTable == NULL");
  assert(function != NULL && "function == NULL");
  int semanticErrors = 0;

  struct Node *funcHeader = getChild(function, 0);

  enum IdentifierType type = TypeNone;
  struct Node *parameters = getChild(funcHeader, 1);
  assert(parameters != NULL && "parameters == NULL");

  if (parameters->tokenType != FuncParams) {
    type = Category2IdentifierType(parameters->tokenType);
    parameters = getChild(funcHeader, 2);
  }

  struct Node *id = getChild(funcHeader, 0);
  struct SymbolList *newSymbol =
      insertSymbol(symbolTable, id->tokenValue, type, function);

  if (newSymbol == NULL) {
    errorSymbol(SYMBOL_ALREADY_DEFINED_ERROR, id);
    return 1;
  }

  struct SymbolList *functionScope = checkScope(newSymbol);

  semanticErrors += checkParams(functionScope, parameters);
  semanticErrors += checkFuncBody(functionScope, getChild(function, 1));

  return semanticErrors;
}

struct SymbolList *checkScope(struct SymbolList *table) {
  // TODO: Implement Scope
  if (table == NULL || table->scope != NULL) {
    return NULL;
  }

  table->scope = malloc(sizeof(*table->scope));
  *table->scope = (struct SymbolList){0};

  return table->scope;
}

int checkParams(struct SymbolList *scopeTable, struct Node *params) {
  if (scopeTable == NULL || params == NULL) {
    return 0;
  }

  int position = 0;
  for (struct Node *param = getChild(params, position); param != NULL;
       param = getChild(params, ++position)) {
    enum IdentifierType type =
        Category2IdentifierType(getChild(param, 0)->tokenType);
    param->identifierType = type;

    struct Node *id = getChild(param, 1);
    if (insertSymbol(scopeTable, id->tokenValue, type, param) == NULL) {
      fprintf(outFile, "Error: identifier already declared: %s\n",
              id->tokenValue);
      return 1;
    }
  }

  return 0;
}

int checkFuncBody(struct SymbolList *scopeTable, struct Node *funcBody) {
  assert(scopeTable != NULL && "scopeTable == NULL");
  assert(funcBody != NULL && "funcBody == NULL");
  int semanticErrors = 0;

  for (struct NodeList *child = funcBody->children; child != NULL;
       child = child->next) {
    struct Node *node = child->node;
    switch (node->tokenType) {
    case VarDecl: {
      semanticErrors += checkVarDecl(scopeTable, node);
    } break;
    case Block:
    case Call:
    case For:
    case If:
    case ParseArgs:
    case Print:
    case Return: {
      semanticErrors += checkStatements(scopeTable, node);
    } break;
    case Add:
    case And:
    case Assign:
    case Div:
    case Eq:
    case Ge:
    case Gt:
    case Le:
    case Lt:
    case Minus:
    case Mod:
    case Mul:
    case Ne:
    case Not:
    case Or:
    case Plus:
    case Sub: {
      semanticErrors += checkExpression(scopeTable, node);
    } break;
    default:
      break;
    }
  }

  return semanticErrors;
}

int checkStatements(struct SymbolList *scopeTable, struct Node *statements) {
  int semanticErrors = 0;

  switch (statements->tokenType) {
  case Block: {
    for (struct NodeList *children = statements->children; (children != NULL);
         children = children->next) {
      semanticErrors += checkStatements(scopeTable, children->node);
    }
  } break;
  case If: {
    semanticErrors += checkExpression(scopeTable, getChild(statements, 0));
    semanticErrors += checkStatements(scopeTable, getChild(statements, 1));
    semanticErrors += checkStatements(scopeTable, getChild(statements, 2));
  } break;
  case For:
    break;
  case Return:
  case Print: {
    semanticErrors += checkExpression(scopeTable, getChild(statements, 0));
  } break;
  case ParseArgs: {
    struct Node *node1 = getChild(statements, 0);
    struct Node *node2 = getChild(statements, 1);
    semanticErrors += checkExpression(scopeTable, node1);
    semanticErrors += checkExpression(scopeTable, node2);
    statements->identifierType =
        (node1->identifierType == node2->identifierType) ? node1->identifierType
                                                         : TypeNone;
  } break;
  case Assign: {
    semanticErrors += checkExpression(scopeTable, getChild(statements, 0));
    semanticErrors += checkExpression(scopeTable, getChild(statements, 1));
  } break;
  default:
    break;
  }

  return semanticErrors;
}

int checkExpression(struct SymbolList *scopeTable, struct Node *expression) {
  (void)scopeTable;

  switch (expression->tokenType) {
  case Natural:
    expression->identifierType = TypeI32;
    break;
  case Decimal:
    expression->identifierType = TypeF32;
    break;
  case Identifier: {
  } break;
  case StrLit:
    expression->identifierType = TypeString;
    break;
  default:
    break;
  }

  return 0;
}

struct SymbolList *createSymbolTable(const struct Node *node) {
  if (node == NULL) {
    return NULL;
  }

  switch (node->tokenType) {
  case FuncDecl: {
    // TODO: FuncDecl
  } break;
  case VarDecl: {
    // TODO: VarDecl
  } break;
  case Identifier: {
    // TODO: Identifier
  } break;

  default: {
    for (struct NodeList *child = node->children; child != NULL;
         child = child->next) {
      if (child == NULL) {
        continue;
      }

      createSymbolTable(child->node);
    }
  } break;
  }

  return NULL;
}

void errorSymbol(const enum SymbolErrorType errorType,
                 const struct Node *node) {
  if (node == NULL) {
    return;
  }

#ifndef RELEASE
  FILE *outFile = stdout;
#else
  FILE *outFile = stderr;
#endif

  fprintf(outFile, "Line %d, column %d: ", node->pos.line, node->pos.column);

  switch (errorType) {
  case SYMBOL_ALREADY_DEFINED_ERROR: {
    fprintf(outFile, "Symbol %s already defined", node->tokenValue);
  } break;
  case SYMBOL_CANNOT_FIND_ERROR: {
    fprintf(outFile, "Cannot find symbol %s", node->tokenValue);
  } break;
  case SYMBOL_UNUSED_ERROR: {
    fprintf(outFile, "Symbol %s declared but never used", node->tokenValue);
  } break;
  case SYMBOL_COERCION_ERROR: {
  } break;
  }

  fprintf(outFile, "\n");
}
