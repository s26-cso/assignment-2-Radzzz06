# Making BST 

# struct memory allocation 
#   Offset 0    int val          (4 bytes) the value of integer stored
#   Offset 4    padding 
#   Offset 8    struct Node* left  (8 bytes)  pointer to left child
#   Offset 16   struct Node* right (8 bytes)  pointer to right child

    .section .text      

# The functions which are linked (C linker)
    .globl make_node
    .globl insert
    .globl get
    .globl getAtMost


#   function 1  struct Node* make_node(int val)

#    Allocate 24 bytes of heap memory using malloc (that is all the data won't be saved in consecutive memory location)
#    node->val = val,  node->left = NULL, node->right = NULL
#    we have to return a pointer to the newly created node

#  argumnet is saved in a0 which is the value which needs to be inserted
#  later a0 holds the pointer to struct made by function


make_node:
    #save ra and s0 because we call malloc
    addi    sp, sp, -16         # allocate 16 bytes on the stack
    sd      ra,  8(sp)          # save return address at sp+8
    sd      s0,  0(sp)          # save s0 at sp, we will use it for storing the int to be inserted

    mv      s0, a0              # s0 = val (saving in s0 as they remain preserved during function)

    # Call malloc(24) to get 24 bytes of heap memory for our new Node
    li      a0, 24              # a0 = 24  (argument to malloc)
    call    malloc              # a0 now becomes pointer to 24 new bytes

    # Now initialize the three fields of the struct:
    sw      s0,   0(a0)         # Node->val = val  , using sw as 4 bytes
    sd      zero, 8(a0)         # Node->left = NULL , using sd to store 8 bytes
    sd      zero, 16(a0)        # Node->right = NULL

    # a0 still holds the node pointer which is our return value

    #restore registers and return the pointer
    ld      s0,  0(sp)
    ld      ra,  8(sp)
    addi    sp, sp, 16
    ret


#  function 2 struct Node* insert(struct Node* root,int val)

#    Move in BST to find the correct place to insetr the value
#    If root is NULL,we return the pointer to struct made by function 1
#    Duplicates are ignored


#    a0 = root (pointer to current node)
#    a1 = val (integer to insert)

#    after the function is completed, a0 = root pointer (unchanged, or new node If tree was NULL)
#

#    If root == NULL then return make_node(val), as the BST is not existing right now
#    If val < root->val then root->left = insert(root->left, val)
#    If val > root->val then root->right = insert(root->right,val)
#    If val == root->val then ignore as duplicate
#    return root

insert:
    #save ra, s0(root), s1(val)
    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      s0, 16(sp)
    sd      s1,  8(sp)

    mv      s0, a0              # s0 = root
    mv      s1, a1              # s1 = val

    # Base case: If root == NULL, use function 1 and return the pointer 
    bnez    s0, comparison
    mv      a0, s1              # argument: val
    call    make_node           # a0 = new node
    j       inserted            # return the new node

comparison:
    lw      t1, 0(s0)               # t1 = root->val
    beq     s1, t1, duplicate       # val == root->val -> duplicate, skip
    blt     s1, t1, go_left         # val <  root->val -> go left

    # Else: val > root->val -> go right

go_right:
    ld      a0, 16(s0)          # a0 = root->right
    mv      a1, s1
    call    insert
    sd      a0, 16(s0)          # root->right = result
    mv      a0, s0
    j       inserted

go_left:
    ld      a0, 8(s0)           # a0 = root->left
    mv      a1, s1
    call    insert
    sd      a0, 8(s0)           # root->left = result
    mv      a0, s0
    j       inserted

duplicate:
    mv      a0, s0              # just return root unchanged

inserted:
    ld      s1,  8(sp)
    ld      s0, 16(sp)
    ld      ra, 24(sp)
    addi    sp, sp, 32
    ret


# function 3  struct Node* get(struct Node* root,int val)

#    Searching an integer and returning a pointer to it, or NULL If not found.

#    a0 = root (pointer to current node, may be NULL)
#    a1 = val  (value to find in BST)

#    AFter function is completed, a0 = pointer to matching node, or NULL (0)

#    If root == NULL then return NULL(not found)
#    If val == root->val then return root(found)
#    If val < root->val then return get(root->left,val)
#    Else return get(root->right,val)

get:
    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      s0, 16(sp)
    sd      s1,  8(sp)

    mv      s0, a0              # s0 = root
    mv      s1, a1              # s1 = val

    # Base case: root == NULL means value not found
    bnez    s0, getCompare
    li      a0, 0               # return NULL
    j       getDone

getCompare:
    lw      t1, 0(s0)           # t1 = root->val
    beq     s1, t1, getFound   # found the match
    blt     s1, t1, getLeft    # val < root->val, serach in left subtree

getRight:
    ld      a0, 16(s0)          # a0 = root->right
    mv      a1, s1
    call    get
    j       getDone

getLeft:
    ld      a0, 8(s0)           # a0 = root->left
    mv      a1, s1
    call    get
    j       getDone

getFound:
    mv      a0, s0              # return pointer to this node

getDone:
    ld      s1,  8(sp)
    ld      s0, 16(sp)
    ld      ra, 24(sp)
    addi    sp, sp, 32
    ret


#   function 4  int getAtMost(int val,struct Node* root)

#    a0 = val  (int)
#    a1 = root (struct Node*, pointer to tree)

#    Return the integer which is like immediate predecessor in in-order traversal of BST
#    Return -1 If the value doesn't exist in tree and all values in tree are greater

#    after function is completed, a0 = int<=val or -1

#    If root == NULL then return -1   
#    If root->val == val then return val
#    If root->val > val then go LEFT
#    If root->val < val then try to find better while remembering the present best, If you fail to find better return present
#    Else continue the process of finding the new better


getAtMost:

    addi    sp, sp, -32
    sd      ra, 24(sp)
    sd      s0, 16(sp)          #s0 (val)
    sd      s1,  8(sp)          #s1 (root)
    sd      s2,  0(sp)          #s2 (root->val predecessor)

    mv      s0, a0              # s0 = val  (the input integer)
    mv      s1, a1              # s1 = root (current node)

    # Base case: root == NULL return -1
    bnez    s1, comparing
    li      a0, -1
    j       gamDone

comparing:
    lw      t1, 0(s1)           # t1 = root->val

    # Case 1: found exact match
    beq     t1, s0, exact

    # Case 2: root->val > val search left subtree
    bgt     t1, s0, Left

    # Case 3: root->val < val trying to find even better value

predecessor:
    mv      s2, t1              # s2 = root->val  (save our best so far)
    mv      a0, s0              # a0 = val
    ld      a1, 16(s1)          # a1 = root->right
    call    getAtMost           # explore right subtree

    # trying to find better
    li      t1, -1
    beq     a0, t1, useSaved         # right returned -1, use our saved value
    j       gamDone                  # right found something, a0 is already set

useSaved:
    mv      a0, s2              # return root->val (best predecessor we saved)
    j       gamDone

Left:
    #go left to find smaller values
    mv      a0, s0              # a0 = val
    ld      a1, 8(s1)           # a1 = root->left
    call    getAtMost
    j       gamDone

exact:
    mv      a0, s0              # return val as exact match found

gamDone:
    ld      s2,  0(sp)
    ld      s1,  8(sp)
    ld      s0, 16(sp)
    ld      ra, 24(sp)
    addi    sp, sp, 32
    ret
