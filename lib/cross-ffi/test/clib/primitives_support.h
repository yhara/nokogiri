
struct prim1 {
  int i ;
  float f ;
  double d ;
  char *c ;
  struct prim1 *next ;
};

struct prim1* prim1_create(int i, float f, double d, char *c, struct prim1* p);
void prim1_get_next(struct prim1* s, struct prim1 **next);
