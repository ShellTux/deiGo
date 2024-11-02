#include "ast.h"
#include <stdio.h>
#include <stdlib.h>

struct node *newnode(enum category category, char *token) {
  struct node *new = malloc(sizeof(struct node));
  new->category = category;
  new->token = token;
  new->children = malloc(sizeof(struct node_list));
  new->children->node = NULL;
  new->children->next = NULL;
  return new;
}

void addchild(struct node *parent, struct node *child) {
  struct node_list *new = malloc(sizeof(struct node_list));
  new->node = child;
  new->next = NULL;
  struct node_list *children = parent->children;
  while (children->next != NULL) {
    children = children->next;
  }
  children->next = new;
}

void print(enum category category, char *token, int depth) {
  (void)category;
  (void)token;
  (void)depth;
}

void show(struct node *node, int depth) {
  (void)node;
  (void)depth;
}
