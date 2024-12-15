#ifndef INCLUDE_INCLUDE_STRING_H_
#define INCLUDE_INCLUDE_STRING_H_

#include <stddef.h>

struct String {
  char *buffer;
  size_t length;
  size_t capacity;
};

void stringAppend(struct String *dest, const char *src);
void stringDestroy(struct String *string);

#endif // INCLUDE_INCLUDE_STRING_H_
