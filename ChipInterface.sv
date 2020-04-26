`default_nettype none

`include "memory/mem_handle.vh"

module ChipInterface (
	input  logic CLOCK_50, GPIO_028, GPIO_031, GPIO_032, GPIO_033,
	output logic GPIO_030);

	
	logic sendrecv;
	logic clk, rst_L;
	logic sclk, ss, miso, mosi;
	
	logic [7:0] byte_send, byte_recv;
	logic valid, write, busy;
							 
	logic cmd_send, cmd_done, cmd_ready;
	
	mem_handle cmd_scratch(), mem_out();
	
	assign clk = CLOCK_50;
	assign rst_L = GPIO_031;
	assign ss = GPIO_033;
	assign sclk = GPIO_032;
	assign mosi = GPIO_028;
	assign GPIO_030 = miso;
	
	spi_module spi_bus(.clk, .rst_L,
							 .sclk, .mosi, .ss, .write,
							 .byte_send, .byte_recv,
							 .valid, .busy,
							 .miso);
							 
	
	cmd_in spi_recv(.clk, .rst_L,
						 .byte_recv, .valid,
						 .cmd_scratch(cmd_scratch), .cmd_ready);
						  
	cmd_out spi_send(.clk, .rst_L,
						  .cmd_send,
						  .mem_out(mem_out),
						  .busy, .write,
						  .cmd_done,
						  .byte_send);
						  
	example_commands example(.clk, .rst_L,
									 .cmd_done, .cmd_ready,
									 .cmd_in(cmd_scratch),
									 .cmd_send,
									 .cmd_out(mem_out));
	

endmodule : ChipInterface