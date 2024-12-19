import data_bus_pkg::*;
import config_pkg::*;

module dma_controller #(
    parameter base_addr_type base_addr = CFG_BADR_DMA,
	parameter addr_mask_type addr_mask = CFG_MADR_DMA
)(
    input logic clk,
    input logic rst,
    input logic [95:0] data_in,
    input logic fifo_empty,
    input logic fifo_full,
    output logic [31:0] data_out

);

    // State definitions
    typedef enum logic [1:0] {
        IDLE,
        READ,
        WRITE
    } state_t;

    state_t state, next_state;

    // Internal signals
    logic [31:0] src_addr, dest_addr, transfer_len;
    logic dma_read, dma_write;
    logic [95:0] prev_data_in;
    logic [31:0] read_data;

    // FSM state transition
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // FSM output logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            src_addr <= 0;
            dest_addr <= 0;
            transfer_len <= 0;
            dma_read <= 0;
            dma_write <= 0;
            data_out <= 0;
        end else begin
            case (state)
                IDLE: begin
                    dma_read <= 0;
                    dma_write <= 0;
                    if (!fifo_empty)
                        if (data_in != prev_data_in) begin
                            src_addr <= data_in[31:24]; // Bits 31 to 24 for source address
                            dest_addr <= data_in[23:16]; // Bits 23 to 16 for destination address
                            transfer_len <= data_in[15:8]; // Bits 15 to 8 for transfer length
                            next_state <= READ;
                        end 
                end
                READ: begin
                    dma_read <= 1;
                    dma_write <= 0;
                end
                WRITE: begin
                    dma_read <= 0;
                    dma_write <= 1;
                end
            endcase
        end
    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            data_out <= 0;
        end else if (dma_read) begin
            data_out <= read_data;
        end else if (dma_write) begin
            data_out <= read_data;
        end
    end


// Instantiate Master Interface
db_reg_intf_master #(
    .base_addr(CFG_BADR_DMA),
    .addr_mask(CFG_BADR_DMA)
) db_reg_intf_master_inst (
    .clk(clk),
    .rst(rst),
    .dma_addr(dma_read ? src_addr : dest_addr),
    .dma_read(dma_read),
    .write_data(read_data),
    .reg_data_o(read_data),
    .dslv(dma_mst)
);

endmodule