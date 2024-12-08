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
#include "codegen.h"

#include "parser.h"
#include "semantics.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// sequence of temporary registers in a function
static int temporary;

extern struct SymbolList *globalSymbolTable;

static int codegen_natural(const struct Node *natural) {
  printf("  %%%d = add i32 %s, 0\n", temporary, natural->tokenValue);
  return temporary++;
}

int codegen_expression(const struct Node *expression) {
  assert(expression != NULL && "expression == NULL");

  int tmp = -1;
  switch (expression->tokenType) {
  case Natural:
    tmp = codegen_natural(expression);
    break;
  default:
    break;
  }
  return tmp;
}

void codegen_parameters(const struct Node *parameters) {
  int curr = 0;
  for (struct Node *parameter = getChild(parameters, curr); parameter != NULL;
       parameter = getChild(parameters, ++curr)) {
    if (curr > 1) {
      printf(", ");
    }

    printf("i32 %%%s", getChild(parameter, 1)->tokenValue);
  }
}

void codegen_function(const struct Node *function) {
  temporary = 1;
  printf("define i32 @_%s(", getChild(function, 0)->tokenValue);
  codegen_parameters(getChild(function, 1));
  printf(") {\n");
  int tmp = codegen_expression(getChild(function, 2));
  printf("  ret i32 %%%d\n", tmp);
  printf("}\n\n");
}

// code generation begins here, with the AST root node
void codegen_program(const struct Node *program) {
  // predeclared I/O functions
  printf("declare i32 @_read(i32)\n");
  printf("declare i32 @_write(i32)\n\n");

  // generate code for each function
  for (struct NodeList *function = program->children; function != NULL;
       function = function->next) {
    codegen_function(function->node);
  }

  // generate the entry point which calls main(integer) if it exists
  struct SymbolList *entry = NULL; // searchSymbol(globalSymbolTable, "main");
  if (entry != NULL && entry->node->tokenType == FuncDecl) {
    printf("define i32 @main() {\n"
           "  %%1 = call i32 @_main(i32 0)\n"
           "  ret i32 %%1\n"
           "}\n");
  }
}
