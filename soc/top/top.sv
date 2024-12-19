import data_bus_pkg::*;
import config_pkg::*;

module lt16soc_top #(
    parameter logic RST_ACTIVE_HIGH = 1'b1
) (
    input logic clk_sys, //clock signal
    input logic rst, //external reset button

    output logic [7 : 0] led
);

    DATA_BUS  db_slv_vector [NSLV-1 : 0] ();
    DATA_BUS  db_mst_vector [NMST-1 : 0] ();

    INSTR_BUS ibus ();

    logic rst_gen;

    logic [15:0] irq_lines;

    assign rst_gen = ~rst;//RST_ACTIVE_HIGH?~rst:rst;
    
    logic clk;

    // Internal signals
    logic [31:0] fifo_data_in [2:0];
    logic [95:0] fifo_data_out;
    logic fifo_full;
    logic fifo_empty;
    logic [31:0] read_data;
    logic ready;

    assign clk = clk_sys;

    clk_div clock_div_inst(
       .clk_out1(clk),                                                                                
       .reset(rst_gen),
       .locked(),
       .clk_in1(clk_sys)
   );

    corewrapper corewrap_inst (
        .clk(clk),
        .rst(rst_gen),
        .irq_lines(irq_lines),
        .imst(ibus),
        .dmst(db_mst_vector[CFG_CORE])
    );

    data_interconnect dicn_inst (
        .clk(clk),
        .rst(rst_gen),
        .mst(db_mst_vector),
        .slv(db_slv_vector)
    );

    memwrapper #(
        .base_addr(CFG_BADR_MEM),
        .addr_mask(CFG_MADR_MEM)
    ) memwrap_inst(
        .clk(clk),
        .rst(rst_gen),
		.fault(),
        .islv(ibus),
		.dslv(db_slv_vector[CFG_MEM])
    );

//     // Instantiate FIFO module
//    fifo_module #(
//        .base_addr(CFG_BADR_DMA),
//        .addr_mask(CFG_MADR_DMA)
//     ) fifo_module_inst (
//        .clk(clk),
//        .rst(rst_gen),
//        .data_in(fifo_data_in),
//        .data_out(fifo_data_out),
//        .full(fifo_full),
//        .empty(fifo_empty)
//    );

//     // Instantiate DMA Controller
//    dma_controller #(
//        .base_addr(CFG_BADR_DMA),
//        .addr_mask(CFG_MADR_DMA)
//     ) dma_controller_inst (
//        .clk(clk),
//        .rst(rst_gen),
//        .data_in(fifo_data_out),
//        .fifo_full(fifo_full),
//        .fifo_empty(fifo_empty),
//        .data_out(read_data)
//     );

    // Instantiate Master Interface
    // db_reg_intf_master #(
    //     .base_addr(CFG_BADR_DMA),
    //     .addr_mask(CFG_MADR_DMA)
    // ) db_reg_intf_master_inst (
    //     .clk(clk),
    //     .rst(rst_gen),
    //     .dma_addr(dma_inst.dma_addr),
    //     .dma_read(dma_inst.dma_read),
    //     .write_data(dma_inst.write_data),
    //     .reg_data_o(read_data),
    //     .ready(ready),
    //     .dslv(db_mst_vector[CFG_DMA])
    // );


endmodule