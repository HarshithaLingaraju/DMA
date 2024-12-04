### Module Descriptions and Interfaces

1. ### db_reg_intf : (Slave_Interface)
   - Description: The DB_REG_INTF (Data Bus Register Interface) module interfaces with the data bus and provides the necessary signals for communication between the DMA controller and the master interface.
   - Interface:

     module db_reg_intf (
         input  logic clk,
         input  logic rst,
         output logic [31:0] reg_data_o, // Data to DMA controller
         DATA_BUS.Master dslv            // Data bus
     );


2. ### FIFO Module:
   - Description: The FIFO (First-In-First-Out) module is used to buffer data frames. It stores incoming data frames and provides them to the DMA controller when requested. The FIFO ensures that data is read in the same order it was written.
   - Interface:

    module fifo #(
        parameter DATA_WIDTH = 32, 
        parameter DEPTH = 16
    )(
        input logic clk,
        input logic rst,
        
        // Data Interface
        input logic [DATA_WIDTH-1:0] data_in,
        output logic full,
        output logic [DATA_WIDTH-1:0] data_out,
        output logic empty
    );


3. ### DMA Controller:
   - Description: The DMA (Direct Memory Access) controller manages the transfer of data between the source and destination addresses. It reads data frames from the FIFO, extracts the source and destination addresses, and controls the read and write operations using the master interface.
   - Interface:

    module dma_controller #(
        parameter DATA_WIDTH = 32, // Width of the data being transferred
        parameter ADDR_WIDTH = 32  // Address width
    )(
        input logic clk,
        input logic rst,
        input logic [DATA_WIDTH-1:0] data_in,
        input logic fifo_empty,
        input logic fifo_full
        output logic [DATA_WIDTH-1:0] data_out

    );


4. ### Master Interface: (Load & Store Interface)
   - Description: The master interface performs the actual read and write operations based on the signals from the DMA controller. It interfaces with the data bus to read data from the source address and write data to the destination address.
   - Interface:

    module master_interface #(
        parameter base_addr_type base_addr = CFG_BADR_LED,
        parameter addr_mask_type addr_mask = CFG_MADR_LED
    ) (
        input  logic clk,
        input  logic rst,
        input  logic [31:0] dma_addr,       // Address from DMA controller
        input  logic dma_read,              // Read signal from DMA controller
        input  logic [31:0] write_data,     // Data to be written to the destination
        output logic [31:0] reg_data_o,     // Data to DMA controller
        output logic ready,                 // Ready signal
        DATA_BUS.Master dslv                // Data bus
    );


