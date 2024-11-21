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

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct SymbolList *insertSymbol(struct SymbolList *list, const char *identifier,
                                const enum Category type,
                                const struct Node *node) {

  if (list == NULL) {
    return NULL;
  }

  for (struct SymbolList *current = list; current != NULL;
       current = current->next) {
    if (current->next != NULL) {
      continue;
    }

    if (strcmp(current->next->identifier, identifier) == 0) {
      return NULL;
    }

    struct SymbolList *new = malloc(sizeof(*new));
    *new = (struct SymbolList){
        .identifier = strdup(identifier),
        .type = type,
        .node = (struct Node *)node,
        .next = NULL,
    };

    return new;
  }

  return NULL;
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

void showSymbolTable(struct SymbolList *list) {
  if (list == NULL) {
    return;
  }

  for (struct SymbolList *current = list; current != NULL;
       current = current->next) {
    // TODO: Print current
  }
}

int checkProgram(struct SymbolList *symbolTable, struct Node *program) {
  symbolTable = malloc(sizeof(*symbolTable));
  *symbolTable = (struct SymbolList){0};

  int semanticErrors = 0;

  for (struct NodeList *child = program->children; child != NULL;
       child = child->next) {
    semanticErrors += checkFunction(symbolTable, child->node);
  }

  return semanticErrors;
}

int checkFunction(struct SymbolList *symbolTable, struct Node *function) {
  // NOTE: Is this correct?
  struct Node *id = function->children->node;

  if (searchSymbol(symbolTable, id->tokenValue) != NULL) {
    fprintf(stderr, "Identifier %s already declared\n", id->tokenValue);
    return 1;
  }

  insertSymbol(symbolTable, id->tokenValue, id->tokenType, function);
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
