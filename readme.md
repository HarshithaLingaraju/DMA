### Module Descriptions and Interfaces

1. ### FIFO Module:
   - Description: The FIFO (First-In-First-Out) module is used to buffer data frames. It stores incoming data frames and provides them to the DMA controller when requested. The FIFO ensures that data is read in the same order it was written.
   - Interface:

     module fifo_module #(
         parameter DATA_WIDTH = 32, // Width of the data being transferred
         parameter ADDR_WIDTH = 32, // Address width
         parameter DEPTH = 16       // Depth of the FIFO
     ) (
         input  logic clk,
         input  logic rst,
         input  logic [DATA_WIDTH-1:0] data_in, // Data input
         output logic [DATA_WIDTH-1:0] data_out, // Data output
         output logic full, // FIFO Full flag
         output logic empty // FIFO Empty flag
     );


2. ### DMA Controller:
   - Description: The DMA (Direct Memory Access) controller manages the transfer of data between the source and destination addresses. It reads data frames from the FIFO, extracts the source and destination addresses, and controls the read and write operations using the master interface.
   - Interface:

     module dma_controller #(
         parameter ADDR_WIDTH = 32,
         parameter DATA_WIDTH = 32
     ) (
         input  logic clk,
         input  logic rst,
         input  logic fifo_empty, // FIFO Empty flag
         input  logic fifo_full,  // FIFO Full flag
         input  logic [DATA_WIDTH-1:0] data_in, // Data input from FIFO
         output logic [DATA_WIDTH-1:0] data_out, // Data output
         DATA_BUS.Master dma_mst // Data bus interface
     );


3. ### Master Interface:
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


4. ### DB_REG_INTF:
   - Description: The DB_REG_INTF (Data Bus Register Interface) module interfaces with the data bus and provides the necessary signals for communication between the DMA controller and the master interface.
   - Interface:

     module db_reg_intf (
         input  logic clk,
         input  logic rst,
         output logic [31:0] reg_data_o, // Data to DMA controller
         DATA_BUS.Master dslv            // Data bus
     );

