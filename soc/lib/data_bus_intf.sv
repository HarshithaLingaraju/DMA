import data_bus_pkg::*;

interface DATA_BUS;

	logic req;
	logic [31:0] addr;
	logic we;
	logic [ 3:0] be;
	logic [31:0] wdata;
	logic gnt;
	logic rvalid;
	logic err;
	logic [31:0] rdata;
	config_type conf;

	modport Master (
				input gnt, rvalid, err, rdata, conf,
				output req, addr, we, be, wdata
	);
	modport Slave (
				input req, addr, we, be, wdata,
				output gnt, rvalid, err, rdata, conf
	);
	
endinterface