
#include "stdlib.h"
#include "string.h"
#include "primitives_support.h"

struct prim1* prim1_create(int i, float f, double d, char *c, struct prim1* p)
{
  struct prim1* s ;
  s = malloc(sizeof(struct prim1)) ;
  s->i = i ;
  s->f = f ;
  s->d = d ;
  s->next = p ;
  s->c = strdup(c) ;
  return s ;
}

void prim1_get_next(struct prim1* s, struct prim1 **next)
{
  *next = s->next ;
}

char* prim1_dup_string(char* input)
{
  return strdup(input);
}
