#include "gocompiler.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

void printCategory(const Category category) {
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

TreeNode *newNode(const Category category, char *token, TreeNode *newBranch) {
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

Node *createNode(const Category category, const char *token) {
  Node *node = malloc(sizeof(Node));
  *node = (Node){.category = category,
                 .token = (char *)(token == NULL ? token : strdup(token)),
                 .children = NULL};
  return node;
}

void printNode(const Node *node, const int depth) {
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
  for (NodeList *children = node->children;
       children != NULL && children->node != NULL; children = children->next) {
    printNode(children->node, depth + 1);
  }
#endif
}

Node *addChild(Node *parent, const Node *childNode) {
  NodeList *childrenNodeList = malloc(sizeof(NodeList));
  assert(childrenNodeList != NULL && "childrenNodeList == NULL");

  *childrenNodeList = (NodeList){
      .next = NULL,
      .node = (Node *)childNode,
  };

  NodeList *child = NULL;

  if (parent->children == NULL) {
    parent->children = childrenNodeList;
    return (Node *)childNode;
  }

  for (child = parent->children; child != NULL && child->next != NULL;
       child = child->next) {
  }
  child->next = childrenNodeList;

  return (Node *)childNode;
}

void printNodeList(const NodeList *nodeList, const int depth) {
  if (nodeList == NULL) {
    return;
  }

  printNode(nodeList->node, depth + 1);
  printNodeList(nodeList->next, depth + 1);
}
