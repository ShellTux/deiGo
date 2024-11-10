#include "gocompiler.h"
#include "stdbool.h"

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

struct Node *createNode(const enum Category tokenType, const char *tokenValue) {
  struct Node *node = malloc(sizeof(*node));
  *node = (struct Node){
      .tokenType = tokenType,
      .tokenValue = tokenValue == NULL ? NULL : strdup(tokenValue),
      .children = NULL,
  };
  return node;
}

struct NodeList *createNodeList(struct Node *node) {
  const struct NodeList empty = {
      .node = node,
      .next = NULL,
  };

  struct NodeList *list = malloc(sizeof(*list));
  *list = empty;

  return list;
}

struct Node *addChild(struct Node *parent, const struct Node *childNode) {
  if (parent == NULL || childNode == NULL) {
    return NULL;
  }

  struct NodeList *childrenNodeList = malloc(sizeof(struct NodeList));
  assert(childrenNodeList != NULL && "childrenNodeList == NULL");

  *childrenNodeList = (struct NodeList){
      .next = NULL,
      .node = (struct Node *)childNode,
  };

  if (parent->children == NULL) {
    parent->children = childrenNodeList;
    return (struct Node *)childNode;
  }

  for (struct NodeList *child = parent->children; child != NULL;
       child = child->next) {
    if (child->next != NULL) {
      continue;
    }

    child->next = childrenNodeList;
    break;
  }

  return (struct Node *)childNode;
}

struct NodeList *addChilds(struct Node *parent, struct NodeList *childList) {
  if (parent == NULL || childList == NULL) {
    return childList;
  }

  for (struct NodeList *child = childList; child != NULL; child = child->next) {
    addChild(parent, child->node);
  }

  destroyList(childList, false);

  return childList;
}

struct NodeList *addNodes(struct NodeList *list1, struct NodeList *list2) {
  if (list1 == NULL || list2 == NULL) {
    return list1;
  }

  for (struct NodeList *list = list2; list != NULL; list = list->next) {
    addNode(list1, list->node);
  }

  destroyList(list2, false);
  return list1;
}

struct Node *addNode(struct NodeList *list, struct Node *node) {
  if (list == NULL || node == NULL) {
    return NULL;
  }

  for (struct NodeList *listC = list; listC != NULL; listC = listC->next) {
    if (listC->next != NULL) {
      continue;
    }

    if (listC->node == NULL) {
      listC->node = node;
    } else {
      listC->next = createNodeList(node);
    }

    break;
  }

  return node;
}

void destroyList(struct NodeList *list, const bool destroyNodes) {
  for (struct NodeList *current = list; current != NULL;) {
    struct NodeList *next = current->next;

    if (destroyNodes) {
      free(current->node);
    }
    free(current);

    current = next;
  }
}

void printNode(const struct Node *node, const int depth) {
  if (node == NULL) {
    return;
  }

  for (int i = 0; i < depth; ++i) {
    printf("..");
  }

  printCategory(node->tokenType);
  if (node->tokenValue != NULL) {
    printf("(%s)", node->tokenValue);
  }
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

void printNodeList(const struct NodeList *nodeList, const int depth) {
  if (nodeList == NULL) {
    return;
  }

  printNode(nodeList->node, depth + 1);
  printNodeList(nodeList->next, depth + 1);
}
