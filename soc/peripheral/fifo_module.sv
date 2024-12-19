module fifo_module #(
    parameter base_addr_type base_addr = CFG_BADR_DMA,
	parameter addr_mask_type addr_mask = CFG_MADR_DMA
)(
    input logic clk,
    input logic rst,
    output logic [95:0] data_out,
    input logic empty,
    input logic full,
    input logic [31:0] data_in [2:0]
);

    // Instantiate Register Interface 
    db_reg_intf #( 
        .base_addr(CFG_BADR_DMA),
        .addr_mask(CFG_MADR_DMA),
        .reg_init(32'h00000000) 
    ) db_reg_intf_inst (
        .clk(clk), 
        .rst(rst), 
        .reg_data_o(data_in),
        .dslv(dslv) 
    ); 
    
    // Instantiate DMA Controller
    dma_controller #( 
        .DATA_WIDTH(96), // Width of the data being transferred 
        .ADDR_WIDTH(ADDR_WIDTH)  // Address width 
    ) dma_controller_inst (
        .clk(clk),
        .rst(rst),
        .fifo_empty(empty), // FIFO Empty flag 
        .fifo_full(full),   // FIFO Full flag 
        .data_in(data_out) 
    );

    localparam DATA_WIDTH = 96;  // Update DATA_WIDTH to 96 bits
    localparam DEPTH = 16;       // Number of elements the FIFO can hold

    logic [DATA_WIDTH-1:0] fifo_mem [0:DEPTH-1];  // FIFO memory, 96 bits wide
    logic [$clog2(DEPTH)-1:0] write_ptr, read_ptr;  // DEPTH = 16: [ \log_2(16) = 4 ]
    logic [$clog2(DEPTH):0] count; 
    logic [31:0] prev_data_in [2:0];
    logic [DATA_WIDTH-1:0] combined_data;  // Combined data element, 96 bits wide

    // Write Logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            write_ptr <= 0;
            count <= 0;
            prev_data_in <= '{0, 0, 0};
        end else if (!full) begin
            // Combine the three 32-bit elements into one 96-bit element
            combined_data <= {data_in[2], data_in[1], data_in[0]};
            fifo_mem[write_ptr] <= combined_data;
            write_ptr <= write_ptr + 1;
            count <= count + 1;
            prev_data_in <= data_in;
        end
    end

    // Read Logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            read_ptr <= 0;
            count <= 0;
        end else if (!empty) begin
            data_out <= fifo_mem[read_ptr];
            read_ptr <= read_ptr + 1;
            count <= count - 1;
        end
    end
endmodule