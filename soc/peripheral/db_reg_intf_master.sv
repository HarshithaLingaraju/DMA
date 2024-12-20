import data_bus_pkg::*;
import config_pkg::*;

module db_reg_intf_master #(
    parameter base_addr_type base_addr = CFG_BADR_DMA,
    parameter addr_mask_type addr_mask = CFG_BADR_DMA
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

    assign dslv.err = 1'b0;
	assign dslv.conf.base_addr = base_addr;
	assign dslv.conf.addr_mask = addr_mask;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset logic
            reg_data_o <= 0;
            ready <= 0;
            dslv.req <= 0;
            dslv.addr <= 0;
            dslv.we <= 0;
            dslv.be <= 4'b1111;
            dslv.wdata <= 0;
        end else begin
            if (dma_read) begin
                // Read operation
                dslv.req <= 1;
                dslv.addr <= dma_addr;
                dslv.we <= 0;
                if (dslv.gnt) begin
                    reg_data_o <= dslv.rdata;
                    ready <= dslv.rvalid;
                    dslv.req <= 0;
                end
            end else begin
                // Write operation
                dslv.req <= 1;
                dslv.addr <= dma_addr;
                dslv.we <= 1;
                dslv.wdata <= write_data;
                if (dslv.gnt) begin
                    ready <= 1;
                    dslv.req <= 0;
                end
            end
        end
    end

endmodule