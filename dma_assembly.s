.global _main

.text
_main:
    li s0, 0x000F0F04   # DMA base address

    # Manually fill the data frame at the start address
    li t0, 0x12345678   # Load a 32-bit value into register t0
    sw t0, 0(s0)        # Store the value from t0 to the address in s0 (0x000F0F04)

    # Write start address to DMA controller
    li t0, 0x000F0F04   # Start address
    sw t0, 4(s0)        # Write start address to DMA register (offset 4)

    # Write destination address to DMA controller
    li t1, 0x20000000   # Destination address
    sw t1, 8(s0)        # Write destination address to DMA register (offset 8)

    # Write transfer length to DMA controller
    li t2, 0x00000010   # Transfer length (e.g., 16 bytes)
    sw t2, 12(s0)       # Write transfer length to DMA register (offset 12)

    # Start DMA transfer (if needed)
    li t3, 0x1          # Control value to start DMA
    sw t3, 0(s0)        # Write control value to DMA register (offset 0)

    # Wait for DMA transfer to complete (polling)
wait_loop:
    lw t3, 0(s0)        # Read control register
    andi t3, t3, 0x1    # Check if DMA is still running
    bnez t3, wait_loop  # If DMA is running, loop

    ret