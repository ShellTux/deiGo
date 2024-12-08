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
#ifndef INCLUDE_INCLUDE_GOCOMPILER_H_
#define INCLUDE_INCLUDE_GOCOMPILER_H_

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

int main(int argc, char **argv);

int yylex(void);
void yyerror(const char *error);

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;

typedef int8_t i8;
typedef int16_t i16;
typedef int32_t i32;
typedef int64_t i64;

struct Pos {
  int line;
  int column;
};

struct Errors {
  int lexer;
  int syntax;
  int semantic;
};

#define DEBUG_MODES                                                            \
  DEBUG_MODE(None, 0, "", "", "")                                              \
  DEBUG_MODE(Lexer, 1 << 0, "-l", "--lexer", "Print Lex tokens")               \
  DEBUG_MODE(Parser, 1 << 1, "-t", "--parser", "Print the AST tree")           \
  DEBUG_MODE(Semantic, 1 << 2, "-s", "--semantic", "Print The Symbol Table")

enum DebugMode {
#define DEBUG_MODE(ENUM, VALUE, SHORT_OPTION, LONG_OPTION, DESCRIPTION)        \
  ENUM = VALUE,
  DEBUG_MODES
#undef DEBUG_MODE
};

#endif // INCLUDE_INCLUDE_GOCOMPILER_H_
// vim:foldmethod=marker
