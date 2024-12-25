.global _main

_main:
    li s0, 0x000F0000   # LED base address
    li s4 , 1
   
    li s1, 0x00010001
    sw s1, 0(s0)

    li s1, 0x00100010
    sw s1, 4(s0)

    li s1, 0x00110011
    sw s1, 8(s0)

    call wait

    li s1, 0x01000100
    sw s1, 0(s0)

    li s1, 0x01010101
    sw s1, 4(s0)

    li s1, 0x01100110
    sw s1, 8(s0)

    call wait

    li s1, 0x01110111
    sw s1, 0(s0)

    li s1, 0x10001000
    sw s1, 4(s0)

    li s1, 0x10011001
    sw s1, 8(s0)

    call wait

wait:
    li t1,0
    inc_i:
        addi t1,t1,1
        ble t1,s4,inc_i
     ret

    