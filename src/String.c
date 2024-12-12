#include "String.h"

#include <stdbool.h>
#include <stdlib.h>
#include <string.h>

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