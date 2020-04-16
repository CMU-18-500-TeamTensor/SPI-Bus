`default_nettype none

module command_process (
	input  logic clk, rst_L,
	input  logic [7:0] command,
	input  logic command_valid,
	input  logic next,
	output logic ready,
	output logic [2:0] count,
	output logic [7:0] buffer);
	
	
	logic [7:0] [7:0] buffers;
	enum logic [2:0] {WAIT, EXECUTE} curr_state, next_state;
	
	
	
	
	
endmodule : command_process