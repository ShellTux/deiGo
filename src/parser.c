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
#include "parser.h"
#include "gocompiler.h"
#include "stdbool.h"

#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern struct Pos syntaxPos;

enum IdentifierType Category2IdentifierType(const enum Category category) {
  switch (category) {
  case Int:
    return TypeI32;
  case Float32:
    return TypeF32;
  case Bool:
    return TypeBool;
  case String:
    return TypeString;
  default:
    break;
  }

  return TypeNone;
}

char *identifierTypeS(const enum IdentifierType type) {
  switch (type) {
#define IDENTIFIER(ENUM, STR)                                                  \
  case ENUM: {                                                                 \
    return STR;                                                                \
  }
    break;
    IDENTIFIER_TYPES
#undef IDENTIFIER
  }

  return NULL;
}

void printIdentifierType(const enum IdentifierType type) {
  switch (type) {
#define IDENTIFIER(ENUM, STR)                                                  \
  case ENUM: {                                                                 \
    printf("%s", #ENUM);                                                       \
  } break;
    IDENTIFIER_TYPES
#undef IDENTIFIER
  }
}

void printType(const enum IdentifierType type) {
  switch (type) {
#define IDENTIFIER(ENUM, STR)                                                  \
  case ENUM: {                                                                 \
    printf("%s", STR);                                                         \
  } break;
    IDENTIFIER_TYPES
#undef IDENTIFIER
  }
}

char *categoryS(const enum Category category) {
  switch (category) {
#define CATEGORY(ENUM)                                                         \
  case ENUM:                                                                   \
    return #ENUM;
    CATEGORIES
#undef CATEGORY
  }

  return NULL;
}

void printCategory(const enum Category category) {
  printf("%s", categoryS(category));
}

struct Node *createNode(const enum Category tokenType, const char *tokenValue) {
  struct Node *node = malloc(sizeof(*node));
  *node = (struct Node){
      .tokenType = tokenType,
      .tokenValue = tokenValue == NULL ? NULL : strdup(tokenValue),
      .pos = syntaxPos,
      .children = NULL,
      .identifierType = TypeNone,
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
    printf(node->tokenType == StrLit ? "(\"%s\")" : "(%s)", node->tokenValue);
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

struct Node *getChild(const struct Node *parent, int position) {
  if (parent == NULL) {
    return NULL;
  }

  for (struct NodeList *child = parent->children; child != NULL;
       child = child->next) {
    if (position-- == 0) {
      return child->node;
    }
  }

  return NULL;
}
