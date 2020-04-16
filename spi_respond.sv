`default_nettype none

module test_backend (
	input  logic clk, rst_L,
	input  logic wr_full, rd_empty,
	input  logic wr_ack, rd_ack,
	input  logic [7:0] rd_buffer,
	output logic [7:0] wr_buffer,
	output logic write, read);

	logic [2:0] count;
	logic [7:0] command;
	logic [7:0] [7:0] cmd_buffer;
	enum logic [2:0] {READ, RETRIEVE, RESPOND} state;

	always_ff @(posedge clk, negedge rst_L)
		if (~rst_L) begin
			count <= 0;
			command <= 0;
			state <= READ;
			wr_buffer <= 0;
			write <= 0;
			read <= 0;
		end else begin
			if (write && wr_ack)
				write <= 0;
			if (read && rd_ack)
				read <= 0;
			case (state)
			READ: begin
				if (~rd_empty && ~read) begin
					
				end
			end
			RETRIEVE: begin
			
			end
			RESPOND: begin
			
			end
			endcase
		end


endmodule : test_backend