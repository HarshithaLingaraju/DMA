.global _main

.text
_main:
    li s0, 0x000F0000   # DMA base address
    li s1, 0x00000000   # to store initial value
    #li s4, 4            # wait counter

    # Manually fill the data frame at the start address
    li t0, 0x00000049   # Load a 32-bit value into register t0
    sw t0, 0(s1)        # Store the value from t0 to the address in s0 (0x000F0F04)

    # Write start address to DMA controller
    li t0, 0x00000000   # Start address
    sw t0, 0(s0)        # Write start address to DMA register (offset 4)

    # Write destination address to DMA controller
    li t1, 0x00000004   # Destination address
    sw t1, 4(s0)        # Write destination address to DMA register (offset 8)

    # Write transfer length to DMA controller
    li t2, 0x00000020   # Transfer length (e.g., 8 bytes)
    sw t2, 8(s0)       # Write transfer length to DMA register (offset 12)

    #call wait

    # Wait for DMA transfer to complete (polling)
#wait:
#    li t1, 0
#inc_i:
#    addi t1, t1, 1
#    ble t1, s4, inc_i
#    ret