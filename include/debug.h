#ifndef INCLUDE_INCLUDE_DEBUG_H_
#define INCLUDE_INCLUDE_DEBUG_H_

#define DEBUG
#ifdef DEBUG
#define DEBUG_PRINT(x, args...)                                                \
  fprintf(stderr, " [%s(), %s:%u]\n" x, __FUNCTION__, __FILE__, __LINE__,      \
          ##args)
#else
#define DEBUG_PRINT(...)
#endif
#undef DEBUG

#endif // INCLUDE_INCLUDE_DEBUG_H_
