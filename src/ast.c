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
#include "ast.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

TreeNode *newNode(char *id, char *token, TreeNode *newBranch) {
  TreeNode *new = malloc(sizeof(TreeNode));
  if (token == NULL) {
    return NULL;
  }

  *new = (TreeNode){
      .token = token,
      .id = id,
      .currentBranch = NULL,
      .newBranch = newBranch,
  };

  return new;
}

void linkInLevel(TreeNode *node, TreeNode *nodeLevel) {
  if (node == NULL) {
    node = nodeLevel;
    return;
  }

  if (nodeLevel == NULL) {
    return;
  }

  TreeNode *tmp = NULL;
  for (tmp = node; tmp->currentBranch != NULL; tmp = tmp->currentBranch) {
  }
  assert(tmp != NULL);
  tmp->currentBranch = nodeLevel;
}

void linkChild(TreeNode *parent, TreeNode *newBranch) {
  if (parent == NULL || newBranch == NULL) {
    return;
  }

  if (parent->newBranch == NULL) {
    parent->newBranch = newBranch;
  } else {
    linkInLevel(parent->newBranch, newBranch);
  }
}

void shiftInsertNode(TreeNode *parent, TreeNode *nodeNew) {
  if (parent == NULL || nodeNew == NULL) {
    return;
  }

  TreeNode *nodeTemp = NULL;
  if (parent->newBranch == NULL) {
    parent->newBranch = nodeNew;
  } else {
    nodeTemp = parent->newBranch;
    parent->newBranch = nodeNew;
    parent->newBranch->currentBranch = nodeTemp;
  }

  TreeNode *auxNode = NULL;
  for (auxNode = parent->currentBranch; auxNode != NULL;
       auxNode = auxNode->currentBranch) {
    nodeTemp = auxNode->newBranch;
    auxNode->newBranch = newNode(NULL, nodeNew->token, NULL);
    auxNode->newBranch->currentBranch = nodeTemp;
  }
}

void show(TreeNode *node, int depth) {
  if (node == NULL) {
    return;
  }

  for (int i = 0; i < depth; i++) {
    printf("..");
  }

  if (node->id != NULL) {
    printf("%s(%s)\n", node->token, node->id);
  } else {
    printf("%s\n", node->token);
  }

  show(node->newBranch, depth + 1);
  show(node->currentBranch, depth);
}
