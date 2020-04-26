`default_nettype none

module spi_module (
	input  logic clk, rst_L,
	input  logic sclk, mosi, ss,
	input  logic write,
	input  logic [7:0] byte_send,
	output logic [7:0] byte_recv,
	output logic valid, busy,
	output logic miso);
	
	
	logic spll, locked;
	logic sendrecv; 
	logic [7:0] buffer_in, buffer_out;
	
	SPI_async spi(.clk(spll),
					  .rst_L, .sclk, .ss, .mosi,
					  .buffer_out, .sendrecv, .buffer_in,
					  .miso);
	
	spi_to_fpga recv(.clk, .sclk(spll), .rst_L,
						  .buffer_in, .sendrecv,
						  .valid, .buffer_out(byte_recv));
	
	fpga_to_spi send(.clk, .sclk(spll), .rst_L,
						  .buffer_in(byte_send),
						  .sendrecv, 
						  .write, .busy,
						  .buffer_out);
	
	sclk_pll spi_pll(.areset(~rst_L),
						  .inclk0(clk),
						  .c0(spll),
						  .locked(locked));
						  
	

endmodule : spi_module