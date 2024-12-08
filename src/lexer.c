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
#include "lexer.h"
#include "gocompiler.h"

#include <stdbool.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

bool isValidString = false;
LexerToken lastToken = L_OTHER;
struct String string = {0};

struct Pos lexerPos = {
    .line = 1,
    .column = 1,
};

struct Pos statePos = {
    .line = -1,
    .column = -1,
};

struct Pos syntaxPos;

extern enum DebugMode debugMode;

extern char *yytext;

void printLex(const char *token, const char *_string) {
  (void)_string;

  if (token == NULL) {
    return;
  }

  printf("%s\n", token);
}

void printLexF(const char *format, const char *string) {
  if (format == NULL || *format == '\0' || string == NULL || *string == '\0') {
    return;
  }

  printf(format, string);
  printf("\n");
}

void printToken(const LexerToken token) {
  if (!(debugMode & Lexer)) {
    return;
  }

  // HACK: Fix
  if (token == L_STRLIT) {
    printf("STRLIT(\"%s\")\n", string.buffer);
    return;
  }

  char *format = NULL;
  char *string = NULL;

  extern char *yytext;

  PrintLexFunction printF = NULL;
  switch (token) {
#define TOKEN(NAME, STRING)                                                    \
  case NAME:                                                                   \
    format = STRING;                                                           \
    printF = printLex;                                                         \
    break;
    TOKENS_WITHOUT_FORMAT
#undef TOKEN
#define TOKEN(NAME, FORMAT)                                                    \
  case NAME:                                                                   \
    format = FORMAT;                                                           \
    string = yytext;                                                           \
    printF = printLexF;                                                        \
    break;
    TOKENS_WITH_FORMAT
#undef TOKEN
  default:
    printf("Invalid Token\n");
    break;
  }

  printF(format, string);
}

void printLastToken(void) { printToken(lastToken); }

bool checkLastToken(void) {
  switch (lastToken) {
  case L_NATURAL:
  case L_DECIMAL:
  case L_STRLIT:
  case L_IDENTIFIER:
  case L_RETURN:
  case L_RPAR:
  case L_RSQ:
  case L_RBRACE:
    printToken(L_SEMICOLON);
    return true;
  default:
    break;
  }

  return false;
}

void stringAppend(struct String *dest, const char *src) {
  if (dest == NULL || src == NULL) {
    return;
  }

  const size_t srcLength = strlen(src);

  if (dest->length + srcLength + 1 > dest->capacity) {
    if (dest->capacity == 0) {
      dest->capacity = 1;
    }

    while (dest->length + srcLength + 1 > dest->capacity) {
      dest->capacity *= 2;
    }

    const bool clean = dest->buffer == NULL;
    dest->buffer =
        realloc(dest->buffer, dest->capacity * sizeof(dest->buffer[0]));

    if (clean) {
      *dest->buffer = '\0';
    }
  }

  strcat(dest->buffer, src);
  dest->length += srcLength;
}

void stringDestroy(struct String *string) {
  if (string == NULL) {
    return;
  }

  if (string->buffer != NULL) {
    free(string->buffer);
  }
  *string = (struct String){0};
}
