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
#ifndef INCLUDE_INCLUDE_LEXER_H_
#define INCLUDE_INCLUDE_LEXER_H_

#include <stdbool.h>
#include <stddef.h>

struct String {
  char *buffer;
  size_t length;
  size_t capacity;
};

void stringAppend(struct String *dest, const char *src);
void stringDestroy(struct String *string);

void tokenPreHook(void);
void nextLine(void);

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

bool checkLastToken(void);
void printLastToken(void);
void printLex(const char *token, const char *_string);
void printLexF(const char *format, const char *string);
void printToken(const LexerToken token);

typedef void (*PrintLexFunction)(const char *, const char *);

#endif // INCLUDE_INCLUDE_LEXER_H_
