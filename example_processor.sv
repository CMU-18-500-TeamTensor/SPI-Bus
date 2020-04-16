`default_nettype none

module example_processor (
	input  logic clk, rst_L,
	input  logic [7:0] byte_recv,
	input  logic valid,
	input  logic busy,
	output logic write,
	output logic [7:0] byte_send);
	
	enum logic [1:0] {WAIT, READ, PREP, WRITE} state;
	
	logic [63:0] [7:0] buffer;
	logic [7:0] index;
	logic [7:0] count;
	
	always_ff @(posedge clk, negedge rst_L)
		if (~rst_L) begin
			write <= 0;
			byte_send <= 0;
			count <= 0;
		end else begin
			write <= 0;
			case (state)
			WAIT: begin
				if (valid) begin
					count <= byte_recv;
					if (byte_recv > 0) begin
						index <= 0;
						state <= READ;
					end
				end
			end
			READ: begin
				if (valid) begin
					buffer[index] <= byte_recv;
					index <= index + 1;
					if (index == count) begin
						index <= 0;
						state <= PREP;
					end
				end
			end
			PREP: begin
				if (~busy && ~write) begin
					write <= 1'b1;
					byte_send <= count;
					state <= WRITE;
				end
			end
			WRITE: begin
				if (~busy && ~write) begin
					write <= 1'b1;
					byte_send <= buffer[index];
					index <= index + 1;
					if (index == count) begin
						state <= WAIT;
					end
				end
			end
			endcase
		end
	
	
endmodule : example_processor