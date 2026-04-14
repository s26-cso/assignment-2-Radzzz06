.section .rodata

filename: .asciz  "input.txt"
mode_r: .asciz  "r"
yes_str: .asciz  "Yes\n"
no_str: .asciz  "No\n"

        .section .text
        .globl main

main:
        addi sp, sp, -32
        sw ra, 28(sp)   # Save return address
        sw s1, 24(sp)   # s1 will hold the FILE pointer
        sw s2, 20(sp)   # s2 will hold the file length
        sw s3, 16(sp)   # s3 is the 'left' index
        sw s4, 12(sp)   # s4 is the 'right' index

        # open the file

        la a0, filename     # Load address of "input.txt"
        la a1, mode_r   
        call fopen
        mv s1, a0   # Copy file pointer to s1

        beqz s1, printNo    # If file pointer is 0 (NULL), jump to error

        # seek to end to get file length

        mv a0, s1           # a0 = file pointer
        li a1, 0            # offset = 0
        li a2, 2
        call fseek

        mv a0, s1
        call ftell          # Get current cursor position (length)
        mv s2, a0           # Store length in s2

        # set up left and right pointers

        li s3, 0
        addi s4, s2, -1     # Right = Length - 1

        # 0 or 1 characters is always a palindrome

        blez s4, printYes

check:
        bge s3, s4, printYes

        # read char at left
        mv a0, s1       # File pointer
        mv a1, s3
        li a2, 0
        call fseek      # SEEK_SET = 0
        mv a0, s1
        call fgetc      # Read one byte
        mv t1, a0       # Store char in t1

        # read char at right
        mv a0, s1
        mv a1, s4       # Current right offset
        li a2, 0        # SEEK_SET = 0
        call fseek
        mv a0, s1
        call fgetc
        mv t2, a0       # Store char in t2

        bne t1, t2, printNo     # If left char != right char, fail

        addi s3, s3, 1
        addi s4, s4, -1
        j check

printYes:
        mv a0, s1       # Close file before exiting
        call fclose
        la a0, yes_str
        call printf
        j done

printNo:
        beqz s1, no_file_to_close     # Don't close if file never opened
        mv a0, s1
        call fclose

no_file_to_close:
        la a0, no_str
        call printf

done:
#empty the stack
        lw ra, 28(sp)
        lw s1, 24(sp)
        lw s2, 20(sp)
        lw s3, 16(sp)
        lw s4, 12(sp)
        addi sp, sp, 32
        li a0, 0
        ret
