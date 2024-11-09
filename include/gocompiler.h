#ifndef INCLUDE_INCLUDE_GOCOMPILER_H_
#define INCLUDE_INCLUDE_GOCOMPILER_H_

#include <stddef.h>

void tokenPreHook(void);
void yyerror(const char *error);
void nextLine(void);

struct Pos {
  int line;
  int column;
};

struct String {
  char *buffer;
  size_t length;
  size_t capacity;
};

void stringAppend(struct String *dest, const char *src);
void stringDestroy(struct String *string);

enum DebugMode {
  None = 0,
  Lexer = 1 << 0,
  Parser = 1 << 1,
};

// Meta 1 {{{

#define TOKENS_WITHOUT_FORMAT                                                  \
  TOKEN(L_SEMICOLON, "SEMICOLON")                                              \
  TOKEN(L_COMMA, "COMMA")                                                      \
  TOKEN(L_BLANKID, "BLANKID")                                                  \
  TOKEN(L_ASSIGN, "ASSIGN")                                                    \
  TOKEN(L_STAR, "STAR")                                                        \
  TOKEN(L_DIV, "DIV")                                                          \
  TOKEN(L_MINUS, "MINUS")                                                      \
  TOKEN(L_PLUS, "PLUS")                                                        \
  TOKEN(L_EQ, "EQ")                                                            \
  TOKEN(L_GE, "GE")                                                            \
  TOKEN(L_GT, "GT")                                                            \
  TOKEN(L_LBRACE, "LBRACE")                                                    \
  TOKEN(L_LE, "LE")                                                            \
  TOKEN(L_LPAR, "LPAR")                                                        \
  TOKEN(L_LSQ, "LSQ")                                                          \
  TOKEN(L_LT, "LT")                                                            \
  TOKEN(L_MOD, "MOD")                                                          \
  TOKEN(L_NE, "NE")                                                            \
  TOKEN(L_NOT, "NOT")                                                          \
  TOKEN(L_AND, "AND")                                                          \
  TOKEN(L_OR, "OR")                                                            \
  TOKEN(L_RBRACE, "RBRACE")                                                    \
  TOKEN(L_RPAR, "RPAR")                                                        \
  TOKEN(L_RSQ, "RSQ")                                                          \
  TOKEN(L_PACKAGE, "PACKAGE")                                                  \
  TOKEN(L_RETURN, "RETURN")                                                    \
  TOKEN(L_ELSE, "ELSE")                                                        \
  TOKEN(L_FOR, "FOR")                                                          \
  TOKEN(L_IF, "IF")                                                            \
  TOKEN(L_VAR, "VAR")                                                          \
  TOKEN(L_INT, "INT")                                                          \
  TOKEN(L_FLOAT32, "FLOAT32")                                                  \
  TOKEN(L_BOOL, "BOOL")                                                        \
  TOKEN(L_STRING, "STRING")                                                    \
  TOKEN(L_PRINT, "PRINT")                                                      \
  TOKEN(L_PARSEINT, "PARSEINT")                                                \
  TOKEN(L_FUNC, "FUNC")                                                        \
  TOKEN(L_CMDARGS, "CMDARGS")
#define TOKENS_WITH_FORMAT                                                     \
  TOKEN(L_RESERVED, "RESERVED(%s)")                                            \
  TOKEN(L_NATURAL, "NATURAL(%s)")                                              \
  TOKEN(L_DECIMAL, "DECIMAL(%s)")                                              \
  TOKEN(L_IDENTIFIER, "IDENTIFIER(%s)")                                        \
  TOKEN(L_STRLIT, "STRLIT(\"%s\")")

#define TOKENS                                                                 \
  TOKENS_WITHOUT_FORMAT                                                        \
  TOKENS_WITH_FORMAT

typedef enum {
  L_OTHER,

#define TOKEN(ENUM, STRING) ENUM,
  TOKENS
#undef TOKEN
} LexerToken;

void checkLastToken(void);
void printLastToken(void);
void printLex(const char *token, const char *_string);
void printLexF(const char *format, const char *string);
void printToken(const LexerToken token);

typedef void (*PrintLexFunction)(const char *, const char *);

// }}}

// Meta 2 {{{

#define TOKEN_ROOT CATEGORY(Program)

/* Declaração de variáveis */
#define TOKEN_VARDECL                                                          \
  CATEGORY(VarDecl)                                                            \
  CATEGORY(Declarations)

/* Declaração/definição de funções */
#define TOKEN_DECL_DEF_FUNC                                                    \
  CATEGORY(FuncDecl)                                                           \
  CATEGORY(FuncHeader)                                                         \
  CATEGORY(FuncParams)                                                         \
  CATEGORY(FuncBody)                                                           \
  CATEGORY(ParamDecl)

/* Statements */
#define TOKEN_STATEMENTS                                                       \
  CATEGORY(Block)                                                              \
  CATEGORY(If)                                                                 \
  CATEGORY(For)                                                                \
  CATEGORY(Return)                                                             \
  CATEGORY(Call)                                                               \
  CATEGORY(Print)                                                              \
  CATEGORY(ParseArgs)

/* Operadores */
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

typedef struct TreeNode {
  enum Category category;
  char *token;
  struct TreeNode *newBranch;
  struct TreeNode *currentBranch;
} TreeNode;

TreeNode *newNode(const enum Category category, char *token,
                  TreeNode *newBranch);
void linkChild(TreeNode *parent, TreeNode *newBranch);
void linkInLevel(TreeNode *node, TreeNode *nodeLevel);
void shiftInsertNode(TreeNode *parent, TreeNode *nodeNew);
void showNode(TreeNode *node, int depth);

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
struct Node *addNode(struct NodeList **nodeList, struct Node *node);

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

// }}}

#endif // INCLUDE_INCLUDE_GOCOMPILER_H_
// vim:foldmethod=marker
