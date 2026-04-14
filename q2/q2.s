.section .rodata
fmt_val:.asciz "%d "
fmt_last:.asciz "%d\n"

.section .text
.globl main

main:
    addi sp, sp, -64
    sw ra, 60(sp)
    sw s0, 56(sp)   # argc (number of students)
    sw s1, 52(sp)   # argv pointer
    sw s2, 48(sp)   # Int array pointer (arr)
    sw s3, 44(sp)   # Result array pointer (res)
    sw s4, 40(sp)   # Stack pointer base
    sw s5, 36(sp)   # Stack top index

    mv s0, a0       # argc
    mv s1, a1       # argv
    
    # Skip the program name (argv[0]), so n = argc - 1
    addi s0, s0, -1 
    blez s0, done 

    # Allocate memory on heap for arr, res, and stack (n * 4 bytes each)
    slli a0, s0, 2  # n * 4
    call malloc
    mv s2, a0       # s2 = arr
    
    slli a0, s0, 2
    call malloc
    mv s3, a0       # s3 = res

    slli a0, s0, 2
    call malloc
    mv s4, a0       # s4 = stack base
    li s5, -1       # stack top = -1 (empty)

    #converting arguments into array
    li t0, 0        # i = 0

input_to_array:
    bge t0, s0, solve_init
    slli t1, t0, 2
    add t1, t1, s1  
    lw a0, 4(t1)    # Load argv[i+1]
    
    # Save t0 because atoi might overwrite it
    addi sp, sp, -4
    sw t0, 0(sp)
    call atoi
    lw t0, 0(sp)
    addi sp, sp, 4
    
    slli t1, t0, 2
    add t1, t1, s2
    sw a0, 0(t1)    # arr[i] = atoi(argv[i+1])
    addi t0, t0, 1
    j input_to_array

#finding the next greater element

solve_init:
    addi s6, s0, -1             # i = n - 1 (Loop backwards)

find_next_greater:
    bltz s6, print_results
    
    # while (!stack.empty() && arr[stack.top()] <= arr[i]) stack.pop()

pop_smaller:
    bltz s5, set_result      # check if stack is empty
    slli t0, s5, 2
    add t0, t0, s4
    lw t1, 0(t0)             # t1 = stack.top()
    
    slli t2, t1, 2
    add t2, t2, s2
    lw t2, 0(t2)             # t2 = arr[stack.top()]
    
    slli t3, s6, 2
    add t3, t3, s2
    lw t3, 0(t3)             # t3 = arr[i]
    
    bgt t2, t3, set_result   # If arr[top] > arr[i], stop popping
    addi s5, s5, -1          # stack.pop()
    j pop_smaller

set_result:
    slli t0, s6, 2
    add t0, t0, s3           # Address of res[i]
    bltz s5, not_found
    
    slli t1, s5, 2
    add t1, t1, s4
    lw t1, 0(t1)             # Get index from stack top
    sw t1, 0(t0)             # res[i] = stack.top()
    j push_current

not_found:
    li t1, -1
    sw t1, 0(t0)             # res[i] = -1

push_current:
    addi s5, s5, 1           # stack.push(i)
    slli t0, s5, 2
    add t0, t0, s4
    sw s6, 0(t0)
    
    addi s6, s6, -1          # i--
    j find_next_greater

#printing the result

print_results:
    li s6, 0                 # i = 0

print_loop:
    bge s6, s0, done
    slli t0, s6, 2
    add t0, t0, s3
    lw a1, 0(t0)             # Load res[i]
    
    # Use different format for the last element to add \n
    
    addi t1, s0, -1
    beq s6, t1, last_val
    la a0, fmt_val
    call printf
    j next_print

last_val:
    la a0, fmt_last
    call printf

next_print:
    addi s6, s6, 1
    j print_loop

done:
 #empty the stack
    lw ra, 60(sp)
    lw s0, 56(sp)
    lw s1, 52(sp)
    lw s2, 48(sp)
    lw s3, 44(sp)
    lw s4, 40(sp)
    lw s5, 36(sp)
    addi sp, sp, 64
    li a0, 0
    ret
