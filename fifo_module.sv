import data_bus_pkg::*;
import config_pkg::*;

module fifo_module #(
    parameter base_addr_type base_addr ,//= CFG_BADR_DMA,
	parameter addr_mask_type addr_mask //= CFG_MADR_DMA
)(
    input logic clk,
    input logic rst,

    input logic [2:0][31:0] data_in,
    output logic [2:0] [31:0] data_out,

    DATA_BUS.Slave dslv
);

logic [2:0] [31:0] fifo_mem [0:15];
logic [3:0] write_ptr, read_ptr;
logic [3:0] count,count1;
logic  [2:0][31:0] prev_data;
logic full , empty;
logic [1:0] write_count,read_count;

    // Instantiate Register Interface 
    db_reg_intf_simple #( 
        .base_addr(base_addr),
        .addr_mask(addr_mask),
        .reg_init(32'h00000000) 
    ) db_reg_intf_inst (
        .clk(clk), 
        .rst(rst), 
        .reg_data_o(data_in),
        .dslv(dslv) 
    ); 

// Write Logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            write_ptr <= 0;
            count <= 0;
            prev_data <= '{default : 0};
	    fifo_mem <= '{default : 0 };
            data_out <= '{default : 0};
            write_count <= 0;
        end else if (!full && prev_data != data_in ) begin
	    fifo_mem[write_ptr][write_count] <= data_in[write_count];
	    write_count <= write_count+1;
            prev_data[write_count] <= data_in[write_count];
	    if(write_count ==2) begin
		write_ptr <= write_ptr +1;
		count <= count +1;
                write_count <= 0;
            end
       end
end

    // Read Logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
	    read_ptr <= 0;
            count1 <= 'b1111;
            prev_data <= 0;
            read_count <= 0;
            fifo_mem <= '{default : 0 };
            data_out <= '{default : 0};
        end else if (!empty && fifo_mem[0][0] != 0) begin
            data_out <= fifo_mem[read_ptr];
            read_count <= read_count + 1;
	    //if ( read_count ==2) begin
               read_ptr <= read_ptr + 1;
	       count1 <= count1 - 1;
               read_count <= 0;
           // end
        end
    end

  always_ff @(posedge clk or posedge rst) begin
	if (rst) begin
	    full <= 0;
	    empty <= 0;
	end else begin
	   full <= (count == 'b1111);
	   empty <= (count1 == 0);
        end
  end
endmodule

   //assign data_out[0] = data[0];
   //assign data_out[1] = data[1];
   //assign data_out[2] = data[2];