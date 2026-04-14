#include <stdio.h>
#include <stdlib.h>
#include <string.h>
struct Node 
{
    int val;              
    struct Node* left;    
    struct Node* right;   
};


struct Node* make_node(int val);
struct Node* insert(struct Node* root, int val);
struct Node* get(struct Node* root, int val);
int getAtMost(int val, struct Node* root);

void inorder(struct Node* root) {
    if (root == NULL) return;
    inorder(root->left);
    printf("%d ",root->val);
    inorder(root->right);
}

int main() 
{
    struct Node* root = NULL;   
    int choice, val, result;
    struct Node* found;

    //1 for insert, 2 for get, 3 for getAtMost, 4 for prinitng in inorder, 5 to exit the while loop

    while (1)
    {
        scanf("%d",&choice);
        switch (choice) 
        {
            case 1:
                scanf("%d",&val);
                root = insert(root, val);
                inorder(root);
                printf("\n");
                break;

            case 2:
                if (root == NULL) 
                {
                    printf("Tree is empty\n");
                    break;
                }
                scanf("%d", &val);
                found = get(root, val);
                if (found)
                    printf("%d",found->val);
                else
                    printf(" %d is not in the tree.\n", val);
                break;

            case 3:
                if (root == NULL) 
                {
                    printf("Tree is empty\n");
                    break;
                }
                scanf("%d", &val);
                result = getAtMost(val, root);
                if (result == -1)
                    printf("No value <= %d exists in the tree.\n", val);
                else
                    printf("Greatest value <= %d is: %d\n", val, result);
                break;

            case 4:
                if (root == NULL) {
                    printf("Tree is empty.\n");
                } else {
                    printf("In-order (sorted): ");
                    inorder(root);
                    printf("\n");
                }
                break;

            case 5:
                return 0;
        }
    }

    return 0;
}
