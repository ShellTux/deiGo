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

struct SymbolList {
  char *identifier;
  enum Category type;
  struct Node *node;
  struct SymbolList *next;
};

int checkProgram(struct SymbolList *symbol_table, struct Node *program);
struct SymbolList *createSymbolTable(const struct Node *node);
struct SymbolList *insertSymbol(struct SymbolList *list, const char *identifier,
                                const enum Category type,
                                const struct Node *node);
struct SymbolList *searchSymbol(const struct SymbolList *list,
                                const char *const identifier);
void showSymbolTable(struct SymbolList *list);
int checkFunction(struct SymbolList *symbolTable, struct Node *function);

#endif // INCLUDE_INCLUDE_SEMANTICS_H_
