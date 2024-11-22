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
#ifndef INCLUDE_INCLUDE_SEMANTICS_H_
#define INCLUDE_INCLUDE_SEMANTICS_H_

#include "parser.h"

#include <stdbool.h>

struct SymbolList {
  char *identifier;
  enum IdentifierType type;
  struct Node *node;
  struct SymbolList *next;
  struct SymbolList *scope;
};

struct SymbolList *createSymbolTable(const struct Node *node);
struct SymbolList *insertSymbol(struct SymbolList *list, const char *identifier,
                                const enum IdentifierType type,
                                const struct Node *node);
struct SymbolList *searchSymbol(const struct SymbolList *list,
                                const char *const identifier);
void showSymbolTable(struct SymbolList *list);
void showSymbolTableFuncDecl(struct SymbolList *list);
void showSymbolTableVarDecl(struct SymbolList *list);

int checkProgram(struct Node *program);
int checkFuncDecl(struct SymbolList *symbolTable, struct Node *funcDecl);
int checkFuncBody(struct SymbolList *symbolTable, struct Node *funcBody);
int checkVarDecl(struct SymbolList *symbolTable, struct Node *varDecl);
int checkParams(struct SymbolList *symbolTable, struct Node *params);
int checkStatements(struct SymbolList *symbolTable, struct Node *params);
int checkExpression(struct SymbolList *symbolTable, struct Node *expression);

bool isParam(const struct Node *param, const struct Node *function);

struct SymbolList *checkScope(struct SymbolList *table);

#endif // INCLUDE_INCLUDE_SEMANTICS_H_
