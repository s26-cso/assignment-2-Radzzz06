    .equ SYS_OPENAT,  56
    .equ SYS_CLOSE,   57
    .equ SYS_LSEEK,   62
    .equ SYS_READ,    63
    .equ SYS_WRITE,   64
    .equ SYS_EXIT,    93
    .equ AT_FDCWD,   -100
    .equ O_RDONLY,    0
    .equ SEEK_SET,    0
    .equ SEEK_END,    2
    .equ STDOUT,      1

    .section .data


filename: .asciz "input.txt"
msg_yes: .asciz "Yes\n"
msg_no: .asciz "No\n"

    .section .text
    .globl _start


#  s0 = file_left(file descriptor reading from the start)
#  s1 = file_right(file descriptor reading from the end)
#  s2 = left_pointer(current left byte offset)
#  s3 = right_pointer(current right byte offset)

_start:
    addi    sp, sp, -8              # 1-byte scratch buffer on the stack

    # open file_left
    li      a7, SYS_OPENAT
    li      a0, AT_FDCWD
    la      a1, filename
    li      a2, O_RDONLY
    li      a3, 0
    ecall
    mv      s0, a0                  # s0 = file_left

    # open file_right
    li      a7, SYS_OPENAT
    li      a0, AT_FDCWD
    la      a1, filename
    li      a2, O_RDONLY
    li      a3, 0
    ecall
    mv      s1, a0                  # s1 = file_right

    # find file length using lseek(file_right, 0, SEEK_END)
    li      a7, SYS_LSEEK
    mv      a0, s1
    li      a1, 0
    li      a2, SEEK_END
    ecall                           # a0 = file length

    li      s2, 0                   # left_pointer  = 0
    addi    s3, a0, -1              # right_pointer = length - 1

    bltz    s3, printYes           # empty file,still palindrome

loop:
    bge     s2, s3, printYes       # pointers met,hence palindrome

    # read left character
    li      a7, SYS_LSEEK
    mv      a0, s0
    mv      a1, s2
    li      a2, SEEK_SET
    ecall
    li      a7, SYS_READ
    mv      a0, s0
    mv      a1, sp
    li      a2, 1
    ecall
    lb      t0, 0(sp)               # t0 = left char

    # read right character
    li      a7, SYS_LSEEK
    mv      a0, s1
    mv      a1, s3
    li      a2, SEEK_SET
    ecall
    li      a7, SYS_READ
    mv      a0, s1
    mv      a1, sp
    li      a2, 1
    ecall
    lb      t1, 0(sp)               # t1 = right char

    bne     t0, t1, printNo        # mismatch hence not a palindrome

    addi    s2, s2, 1               # left_pointer++
    addi    s3, s3, -1              # right_pointer--
    j       loop

printYes:
    li      a7, SYS_WRITE
    li      a0, STDOUT
    la      a1, msg_yes
    li      a2, 4
    ecall
    j       closure

printNo:
    li      a7, SYS_WRITE
    li      a0, STDOUT
    la      a1, msg_no
    li      a2, 3
    ecall

closure:
    li      a7, SYS_CLOSE
    mv      a0, s0
    ecall
    li      a7, SYS_CLOSE
    mv      a0, s1
    ecall
    addi    sp, sp, 8
    li      a7, SYS_EXIT
    li      a0, 0
    ecall
