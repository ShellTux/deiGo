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
#include "parser.h"
#include "stdbool.h"

#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct SymbolList *globalSymbolTable = NULL;

struct SymbolList *insertSymbol(struct SymbolList *table,
                                const char *identifier,
                                const enum IdentifierType type,
                                const struct Node *node) {
  struct SymbolList *new = NULL;

  for (struct SymbolList *symbol = table; symbol != NULL;
       symbol = symbol->next) {
    if (symbol->next != NULL) {
      continue;
    }

    if (strcmp(symbol->next->identifier, identifier) == 0) {
      return NULL;
    }

    new = malloc(sizeof(*new));
    *new = (struct SymbolList){
        .identifier = strdup(identifier),
        .type = type,
        .node = (struct Node *)node,
        .next = NULL,
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

static void printParams(const struct Node *node) {
  struct Node *funcHeader = getChild((struct Node *)node, 0);
  struct Node *funcParams = getChild((struct Node *)funcHeader, 1);
  if (funcParams->tokenType != FuncParams) {
    funcParams = getChild(funcHeader, 2);
  }

  for (struct NodeList *children = funcParams->children; children != NULL;
       children = children->next) {
    printIdentifierType(Category2IdentifierType(children->node->tokenType));
    if (children->next != NULL) {
      printf(", ");
    }
  }
}

static void showFunction(struct SymbolList *symbol, const struct Node *node) {
  printf("===== Function %s(", symbol->identifier);
  printParams(symbol->node);
  printf(") Symbol Table =====\n");

  printf("return\t\t");
  printIdentifierType(symbol->type);
  printf("\n");

  for (struct SymbolList *scopeTable = symbol->scope; scopeTable != NULL;
       scopeTable = scopeTable->next) {
    printf("%s\t\t", scopeTable->identifier);
    printIdentifierType(scopeTable->type);
    printf(isParam(scopeTable->node, node) ? "\tparam\n" : "\n");
  }

  printf("\n");
}

bool isParam(const struct Node *param, const struct Node *function) {
  struct Node *header = getChild((struct Node *)function, 0);
  struct Node *params = getChild(header, 1);

  if (params->tokenType != FuncParams) {
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

  printf("===== Global Symbol Table =====\n");

  for (struct SymbolList *symbol = symbolTable->next; symbol != NULL;
       symbol = symbol->next) {
    const struct Node *node = symbol->node;

    switch (node->tokenType) {
    case FuncDecl: {
      showSymbolTableFuncDecl(symbol);
    } break;
    case VarDecl: {
      showSymbolTableVarDecl(symbol);
    } break;
    default:
      break;
    }
  }

  printf("\n");

  for (struct SymbolList *symbol = globalSymbolTable->next; symbol != NULL;
       symbol = symbol->next) {
    const struct Node *node = symbol->node;
    if (node->tokenType != FuncDecl) {
      continue;
    }

    showFunction(symbol, node);
  }
}

void showSymbolTableFuncDecl(struct SymbolList *symbolTable) {
  return;
  printf("===== Function %s(", symbolTable->identifier);
  printParams(symbolTable->node);
  printf(") Symbol Table =====\n");
}

void showSymbolTableVarDecl(struct SymbolList *symbolTable) {
  return;
  printf("===== Function %s(", symbolTable->identifier);
  printIdentifierType(symbolTable->type);
  printf(") Symbol Table =====\n");
}

int checkProgram(struct Node *program) {
  int semanticErrors = 0;

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

int checkVarDecl(struct SymbolList *scope, struct Node *var) {
  return 0;

  struct Node *id = getChild(var, 1);
  enum IdentifierType type =
      Category2IdentifierType(getChild(var, 0)->tokenType);
  if (insertSymbol(scope, id->tokenValue, type, var) == NULL) {
    printf("Error: identifier already declared: %s\n", id->tokenValue);
    return 1;
  }

  return 0;
}

int checkFuncDecl(struct SymbolList *symbolTable, struct Node *function) {
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
    printf("Error: identifier already declared: %s\n", id->tokenValue);
    return 1;
  }

  struct SymbolList *functionScope = checkScope(newSymbol);

  semanticErrors += checkParams(functionScope, parameters);

  struct Node *functionBody = getChild(function, 1);
  semanticErrors += checkFuncBody(functionScope, functionBody);

  return semanticErrors;
}

struct SymbolList *checkScope(struct SymbolList *table) {
  if (table == NULL || table->scope != NULL) {
    return NULL;
  }

  return table->scope = malloc(sizeof(*table->scope));
}

int checkParams(struct SymbolList *scopeTable, struct Node *params) {
  int position = 0;
  for (struct Node *param = getChild(params, position); param != NULL;
       param = getChild(params, ++position)) {
    enum IdentifierType type =
        Category2IdentifierType(getChild(param, 0)->tokenType);
    param->identifierType = type;

    struct Node *id = getChild(param, 1);
    if (insertSymbol(scopeTable, id->tokenValue, type, param) == NULL) {
      printf("Error: identifier already declared: %s\n", id->tokenValue);
      return 1;
    }
  }

  return 0;
}

int checkFuncBody(struct SymbolList *scopeTable, struct Node *funcBody) {
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
