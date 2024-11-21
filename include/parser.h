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
#ifndef INCLUDE_INCLUDE_PARSER_H_
#define INCLUDE_INCLUDE_PARSER_H_

#include <stdbool.h>

#define TOKEN_ROOT CATEGORY(Program)

#define TOKEN_VARDECL                                                          \
  CATEGORY(VarDecl)                                                            \
  CATEGORY(Declarations)

#define TOKEN_DECL_DEF_FUNC                                                    \
  CATEGORY(FuncDecl)                                                           \
  CATEGORY(FuncHeader)                                                         \
  CATEGORY(FuncParams)                                                         \
  CATEGORY(FuncBody)                                                           \
  CATEGORY(ParamDecl)

#define TOKEN_STATEMENTS                                                       \
  CATEGORY(Block)                                                              \
  CATEGORY(If)                                                                 \
  CATEGORY(For)                                                                \
  CATEGORY(Return)                                                             \
  CATEGORY(Call)                                                               \
  CATEGORY(Print)                                                              \
  CATEGORY(ParseArgs)

#define TOKEN_OPERATORS                                                        \
  CATEGORY(Or)                                                                 \
  CATEGORY(And)                                                                \
  CATEGORY(Eq)                                                                 \
  CATEGORY(Ne)                                                                 \
  CATEGORY(Lt)                                                                 \
  CATEGORY(Gt)                                                                 \
  CATEGORY(Le)                                                                 \
  CATEGORY(Ge)                                                                 \
  CATEGORY(Add)                                                                \
  CATEGORY(Sub)                                                                \
  CATEGORY(Mul)                                                                \
  CATEGORY(Div)                                                                \
  CATEGORY(Mod)                                                                \
  CATEGORY(Not)                                                                \
  CATEGORY(Minus)                                                              \
  CATEGORY(Plus)                                                               \
  CATEGORY(Star)                                                               \
  CATEGORY(Assign)

#define TOKEN_TERMINAL                                                         \
  CATEGORY(Int)                                                                \
  CATEGORY(Float32)                                                            \
  CATEGORY(Bool)                                                               \
  CATEGORY(String)                                                             \
  CATEGORY(Natural)                                                            \
  CATEGORY(Decimal)                                                            \
  CATEGORY(Identifier)                                                         \
  CATEGORY(StrLit)

#define CATEGORIES                                                             \
  TOKEN_ROOT                                                                   \
  TOKEN_VARDECL                                                                \
  TOKEN_DECL_DEF_FUNC                                                          \
  TOKEN_STATEMENTS                                                             \
  TOKEN_OPERATORS                                                              \
  TOKEN_TERMINAL

enum Category {
#define CATEGORY(ENUM) ENUM,
  CATEGORIES
#undef CATEGORY
};

void printCategory(const enum Category category);

/**
 * @struct Node
 * Represents a node in a tree-like structure.
 *
 * @var tokenType
 * The category/type of token associated with the node.
 *
 * @var tokenValue
 * A string that holds the value of the token. Must be dynamically allocated
 * (strdup).
 *
 * @var children
 * A linked list of child nodes, which are also of type Node. (All children are
 * in the same level)
 */
struct Node {
  enum Category tokenType;
  char *tokenValue;
  struct NodeList *children;
};

/**
 * @struct NodeList
 * Represents a linked list of Node pointers.
 *
 * @var node
 * A pointer to the Node that this list entry points to.
 *
 * @var next
 * A pointer to the next entry in the linked list.
 */
struct NodeList {
  struct Node *node;
  struct NodeList *next;
};

/**
 * @function addChild
 * Adds a child node to the end of the linked-list of a parent node's children.
 *
 * @param parent A pointer to the parent node to which the child will be added.
 * @param child A constant pointer to the child node to be added.
 * @return A pointer to the added child node.
 */
struct Node *addChild(struct Node *parent, const struct Node *child);

/**
 * @function addChilds
 * Adds multiple child nodes from a linked list to the end of the linked-list of
 * a parent node's children.
 *
 * @param parent A pointer to the parent node.
 * @param childList A pointer to the linked list of child nodes to be added.
 * @return A pointer to childList.
 */
struct NodeList *addChilds(struct Node *parent, struct NodeList *childList);

/**
 * @function createNode
 * Creates a new node with a specified token type and value. This function
 * necessarily allocates a space in heap for the new node.
 *
 * @param tokenType The type of the token for the new node.
 * @param tokenValue The value of the token for the new node.
 * @return A pointer to the newly dynamically allocated created node.
 */
struct Node *createNode(const enum Category tokenType, const char *tokenValue);

/**
 * @function createNodeList
 * Creates a new NodeList containing a single node. The node is dynamically
 * allocated in the heap and linked into the list.
 *
 * @param node A pointer to the Node to be added to the new NodeList. This node
 * must be dynamically allocated before calling this function.
 *
 * @return A pointer to the newly created NodeList containing the given node. If
 * the input node is NULL, the function will return an empty list
 * {.node = NULL, .next = NULL}.
 *
 * @note The caller is responsible for freeing the memory associated with the
 * created NodeList and its nodes when they are no longer needed to avoid memory
 * leaks.
 */
struct NodeList *createNodeList(struct Node *node);

/**
 * @function addNodes
 * Appends all nodes from the second linked list to the first linked list.
 *
 * @param list1 A pointer to the first linked list.
 * @param list2 A pointer to the second linked list to be appended.
 * @return A pointer to the modified first linked list.
 */
struct NodeList *addNodes(struct NodeList *list1, struct NodeList *list2);

/**
 * @function addNode
 * Adds a single node to the end of a linked list of nodes.
 * if (nodeList == NULL || node == NULL) => nothing
 *
 * if (*nodeList == NULL) => create NodeList
 *
 * @param nodeList A pointer to a pointer to the linked list where the node will
 * be added.
 * @param node A pointer to the node to be added.
 * @return A pointer to the modified linked list.
 */
struct Node *addNode(struct NodeList *nodeList, struct Node *node);

/**
 * @function destroyList
 * Cleans up and frees the memory associated with a linked list of nodes.
 * Optionally destroys the individual nodes in the list.
 *
 * @param list A pointer to the linked list to be destroyed. The list itself
 * will be freed, but if `destroyNodes` is true, the individual nodes will also
 * be freed.
 *
 * @param destroyNodes A boolean value that determines whether to free the
 * memory of the nodes within the linked list. If true, each node will be freed;
 *                     if false, only the list structure will be freed, leaving
 *                     the nodes intact.
 *
 * @return void This function does not return a value. It is intended for side
 * effects of memory management.
 *
 * @note It is the caller's responsibility to ensure that the linked list is
 * properly allocated before calling this function to avoid undefined behavior.
 */
void destroyList(struct NodeList *list, const bool destroyNodes);

/**
 * @function printNode
 * Prints the details of a node with indentation based on depth.
 *
 * @param node A pointer to the node to print.
 * @param depth An integer representing the depth level for indentation.
 */
void printNode(const struct Node *node, const int depth);

/**
 * @function printNodeList
 * Prints the details of a linked list of nodes with indentation based on depth.
 *
 * @param nodeList A pointer to the linked list of nodes to print.
 * @param depth An integer representing the depth level for indentation.
 */
void printNodeList(const struct NodeList *nodeList, const int depth);

#endif // INCLUDE_INCLUDE_PARSER_H_
