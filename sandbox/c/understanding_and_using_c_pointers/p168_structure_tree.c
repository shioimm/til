// 詳説Cポインタ P168

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct _employee {
  char name[32];
  unsigned int age;
} Employee;

int compare(Employee *e1, Employee *e2)
{
  return strcmp(e1->name, e2->name);
}

void display(Employee *e)
{
  printf("%s\t%d\n", e->name, e->age);
}

typedef int (*COMPARE)(void*, void*);
typedef void (*DISPLAY)(void*);

typedef struct _tree {
  void *data;
  struct _tree *left;
  struct _tree *right;
} TreeNode;

void insert_node(TreeNode **real_root, COMPARE compare, void *data)
{
  TreeNode *node = malloc(sizeof(TreeNode));
  node->data = data;
  node->left = NULL;
  node->right = NULL;

  TreeNode *root = *real_root;

  if (root == NULL) {
    *real_root = node;
    return;
  }

  while (1) {
    if (compare((root)->data, data) > 0) {
      if ((root)->left != NULL) {
        root = (root)->left;
      } else {
        (root)->left = node;
        break;
      }
    } else {
      if ((root)->right != NULL) {
        root = (root)->right;
      } else {
        (root)->right = node;
        break;
      }
    }
  }
}

void in_order(TreeNode *root, DISPLAY display)
{
  if (root != NULL) {
    in_order(root->left, display);
    display(root->data);
    in_order(root->right, display);
  }
}

void post_order(TreeNode *root, DISPLAY display)
{
  if (root != NULL) {
    post_order(root->left, display);
    post_order(root->right, display);
    display(root->data);
  }
}

void pre_order(TreeNode *root, DISPLAY display)
{
  if (root != NULL) {
    display(root->data);
    pre_order(root->left, display);
    pre_order(root->right, display);
  }
}

int main(void)
{
  TreeNode *tree = NULL;

  Employee *alice = malloc(sizeof(Employee));
  strcpy(alice->name, "Alice");
  alice->age = 30;

  Employee *bob = malloc(sizeof(Employee));
  strcpy(bob->name, "Bob");
  bob->age = 40;

  Employee *carol = malloc(sizeof(Employee));
  strcpy(carol->name, "Carol");
  carol->age = 50;

  insert_node(&tree, (COMPARE)compare, alice);
  insert_node(&tree, (COMPARE)compare, bob);
  insert_node(&tree, (COMPARE)compare, carol);

  pre_order(tree, (DISPLAY)display);
  in_order(tree, (DISPLAY)display);
  post_order(tree, (DISPLAY)display);

  return 0;
}
