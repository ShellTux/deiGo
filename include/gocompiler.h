#ifndef INCLUDE_INCLUDE_GOCOMPILER_H_
#define INCLUDE_INCLUDE_GOCOMPILER_H_

#include <stddef.h>

void tokenPreHook(void);
void yyerror(const char *error);
void nextLine(void);

typedef struct {
  int line;
  int column;
} Pos;

typedef struct {
  char *buffer;
  size_t length;
  size_t capacity;
} String;

void stringAppend(String *dest, const char *src);
void stringDestroy(String *string);

typedef enum {
  None = 0,
  Lexer = 1 << 0,
  Parser = 1 << 1,
} DebugMode;

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
  Category category;
  char *token;
  struct TreeNode *newBranch;
  struct TreeNode *currentBranch;
} TreeNode;

typedef TreeNode Node;

TreeNode *newNode(const Category category, char *token, TreeNode *newBranch);
void linkChild(TreeNode *parent, TreeNode *newBranch);
void linkInLevel(TreeNode *node, TreeNode *nodlevel);
void shiftInsertNode(TreeNode *parent, TreeNode *newnod);
void showNode(TreeNode *node, int depth);

// }}}

#endif // INCLUDE_INCLUDE_GOCOMPILER_H_
// vim:foldmethod=marker
