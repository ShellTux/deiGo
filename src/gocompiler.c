#include "gocompiler.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

void printCategory(const enum Category category) {
  char *categoryS = NULL;
  switch (category) {
#define CATEGORY(ENUM)                                                         \
  case ENUM: {                                                                 \
    categoryS = #ENUM;                                                         \
  } break;
    CATEGORIES
#undef CATEGORY
  }

  printf("%s", categoryS);
}

TreeNode *newNode(const enum Category category, char *token, TreeNode *newBranch) {
  TreeNode *new = malloc(sizeof(TreeNode));
  if (token == NULL) {
    return NULL;
  }

  *new = (TreeNode){
      .token = token,
      .category = category,
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

  TreeNode *temp = NULL;
  if (parent->newBranch == NULL) {
    parent->newBranch = nodeNew;
  } else {
    temp = parent->newBranch;
    parent->newBranch = nodeNew;
    parent->newBranch->currentBranch = temp;
  }

  for (TreeNode *aux = parent->currentBranch; aux != NULL;
       aux = aux->currentBranch) {
    temp = aux->newBranch;
    // TODO: Fix hardcoded category
    aux->newBranch = newNode(Program, nodeNew->token, NULL);
    aux->newBranch->currentBranch = temp;
  }
}

void showNode(TreeNode *node, int depth) {
  if (node == NULL) {
    return;
  }

  for (int i = 0; i < depth; i++) {
    printf("..");
  }

  printCategory(node->category);

  if (node->token != NULL) {
    printf("(%s)", node->token);
  }

  printf("\n");

  showNode(node->newBranch, depth + 1);
  showNode(node->currentBranch, depth);
}

struct Node *createNode(const enum Category category, const char *token) {
  struct Node *node = malloc(sizeof(struct Node));
  *node = (struct Node){.category = category,
                 .token = (char *)(token == NULL ? token : strdup(token)),
                 .children = NULL};
  return node;
}

void printNode(const struct Node *node, const int depth) {
  if (node == NULL) {
    return;
  }

  for (int i = 0; i < depth; ++i) {
    printf("..");
  }

  printCategory(node->category);
  printf("\n");

#if 0
  printNodeList(node->children, depth);
#else
  for (struct NodeList *children = node->children;
       children != NULL && children->node != NULL; children = children->next) {
    printNode(children->node, depth + 1);
  }
#endif
}

struct Node *addChild(struct Node *parent, const struct Node *childNode) {
  struct NodeList *childrenNodeList = malloc(sizeof(struct NodeList));
  assert(childrenNodeList != NULL && "childrenNodeList == NULL");

  *childrenNodeList = (struct NodeList){
      .next = NULL,
      .node = (struct Node *)childNode,
  };

  struct NodeList *child = NULL;

  if (parent->children == NULL) {
    parent->children = childrenNodeList;
    return (struct Node *)childNode;
  }

  for (child = parent->children; child != NULL && child->next != NULL;
       child = child->next) {
  }
  child->next = childrenNodeList;

  return (struct Node *)childNode;
}

void printNodeList(const struct NodeList *nodeList, const int depth) {
  if (nodeList == NULL) {
    return;
  }

  printNode(nodeList->node, depth + 1);
  printNodeList(nodeList->next, depth + 1);
}
