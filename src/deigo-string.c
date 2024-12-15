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
#include "deigo-string.h"

#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

#define STATIC_STRINGS_MAX 10

struct StaticStrings {
  struct String buffers[STATIC_STRINGS_MAX];
  size_t index;
};

static struct StaticStrings staticStrings = {0};

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

struct String *getStaticString(const char *const initialString) {
  struct String *string = &staticStrings.buffers[staticStrings.index++];

  stringDestroy(string);
  stringAppend(string, initialString);

  return string;
}
