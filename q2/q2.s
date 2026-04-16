.section .rodata
fmt_val:    .asciz "%d "
fmt_last:   .asciz "%d\n"

.section .text
.globl main

main:

    addi sp, sp, -80
    sd ra, 72(sp)
    sd s0, 64(sp)   # argc / n
    sd s1, 56(sp)   # argv pointer
    sd s2, 48(sp)   # arr pointer
    sd s3, 40(sp)   # res pointer
    sd s4, 32(sp)   # stack base pointer
    sd s5, 24(sp)   # stack top index
    sd s6, 16(sp)   # loop counter i
    sd s7, 8(sp)    # secondary loop counter

    mv s0, a0       # argc
    mv s1, a1       # argv
    
    # Skip argv[0] (program name), so n = argc - 1
    addi s0, s0, -1 
    blez s0, done 

    # Allocate memory on heap (n * 4 bytes for 32-bit integers)
    slli a0, s0, 2  
    call malloc
    mv s2, a0       # s2 = arr
    
    slli a0, s0, 2
    call malloc
    mv s3, a0       # s3 = res

    slli a0, s0, 2
    call malloc
    mv s4, a0       # s4 = stack base
    li s5, -1       # stack top = -1 (empty)

    # 1. Convert arguments into array
    li s7, 0        # i = 0

input_to_array:
    bge s7, s0, solve_init
    
    #argv is an array of 64-bit pointers (8 bytes each)
    slli t1, s7, 3  # i * 8
    add t1, t1, s1  
    ld a0, 8(t1)    # Load argv[i+1] 


    # Call atoi (no need to save s7 to stack, it's callee-saved)
    call atoi
    
    # Store 32-bit integer into arr[i]
    slli t1, s7, 2  # i * 4
    add t1, t1, s2
    sw a0, 0(t1)    # arr[i] = atoi(argv[i+1])
    
    addi s7, s7, 1
    j input_to_array

    # 2. Find the Next Greater Element
solve_init:
    addi s6, s0, -1          # i = n - 1 (Loop backwards)

find_next_greater:
    bltz s6, print_results

     # while (!stack.empty() && arr[stack.top()] <= arr[i]) stack.pop()
pop_smaller:

    bltz s5, set_result      # check if stack is empty
    slli t0, s5, 2
    add t0, t0, s4
    lw t1, 0(t0)             # t1 = stack.top() (Index)
    
    slli t2, t1, 2
    add t2, t2, s2
    lw t2, 0(t2)             # t2 = arr[stack.top()] (Value)
    
    slli t3, s6, 2
    add t3, t3, s2
    lw t3, 0(t3)             # t3 = arr[i]
    
    bgt t2, t3, set_result   # If arr[stack.top()] > arr[i], stop popping
    addi s5, s5, -1          # stack.pop()
    j pop_smaller

set_result:
    slli t0, s6, 2
    add t0, t0, s3           # Address of res[i]
    bltz s5, not_found
    
    slli t1, s5, 2
    add t1, t1, s4
    lw t1, 0(t1)             # Get index from stack top
    
    slli t2, t1, 2
    add t2, t2, s2
    lw t2, 0(t2)             # Get VALUE of NGE: arr[stack.top()]
    sw t2, 0(t0)             # res[i] = value
    j push_current

not_found:
    li t1, -1
    sw t1, 0(t0)             # res[i] = -1

push_current:
    addi s5, s5, 1           # stack.push(i)
    slli t0, s5, 2
    add t0, t0, s4
    sw s6, 0(t0)             # Store index
    
    addi s6, s6, -1          # i--
    j find_next_greater

    # 3. Print the result
print_results:
    li s6, 0                 # i = 0

print_loop:
    bge s6, s0, done
    slli t0, s6, 2
    add t0, t0, s3
    lw a1, 0(t0)             # Load res[i] for printf
    
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
    # empty stack
    ld ra, 72(sp)
    ld s0, 64(sp)
    ld s1, 56(sp)
    ld s2, 48(sp)
    ld s3, 40(sp)
    ld s4, 32(sp)
    ld s5, 24(sp)
    ld s6, 16(sp)
    ld s7, 8(sp)
    addi sp, sp, 80
    
    li a0, 0
    ret
