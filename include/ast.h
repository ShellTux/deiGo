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
#ifndef _AST_H
#define _AST_H

#define CATEGORIES                                                             \
  CATEGORY(Program)                                                            \
  CATEGORY(Function)                                                           \
  CATEGORY(Parameters)                                                         \
  CATEGORY(Parameter)                                                          \
  CATEGORY(Arguments)                                                          \
  CATEGORY(Integer)                                                            \
  CATEGORY(Double)                                                             \
  CATEGORY(Identifier)                                                         \
  CATEGORY(Natural)                                                            \
  CATEGORY(Decimal)                                                            \
  CATEGORY(Call)                                                               \
  CATEGORY(If)                                                                 \
  CATEGORY(Add)                                                                \
  CATEGORY(Sub)                                                                \
  CATEGORY(Mul)                                                                \
  CATEGORY(Div)

typedef enum category {
#define CATEGORY(ENUM) ENUM,
  CATEGORIES
#undef CATEGORY
} Category;

void printCategory(const Category category);

typedef struct TreeNode {
  char *token;
  char *id;
  struct TreeNode *newBranch;
  struct TreeNode *currentBranch;
} TreeNode;

TreeNode *newNode(char *id, char *token, TreeNode *newBranch);
void linkInLevel(TreeNode *node, TreeNode *nodeLevel);
void linkChild(TreeNode *parent, TreeNode *newBranch);
void shiftInsertNode(TreeNode *parent, TreeNode *nodeNew);
void show(TreeNode *node, int depth);

#endif
