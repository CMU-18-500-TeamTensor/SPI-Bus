`default_nettype none

module example_processor (
	input  logic clk, rst_L,
	input  logic [7:0] byte_recv,
	input  logic valid,
	input  logic busy,
	output logic write,
	output logic [7:0] byte_send,
	output logic [7:0] LED);
	
	enum logic [2:0] {WAIT, COUNT, READ, FLAG, PREP, WRITE} state;
	
	logic [15:0][3:0][7:0] buffer;
	logic [7:0] index;
	logic [1:0] index_word;
	logic [31:0] count;
	logic [31:0] count_buf;
	
	assign LED = {count[1:0], index_word, 1'b0, state};
	
	always_ff @(posedge clk, negedge rst_L)
		if (~rst_L) begin
			write <= 0;
			byte_send <= 0;
			index <= 0;
			index_word <= 0;
			count <= 0;
			count_buf <= 0;
			state <= WAIT;
		end else begin
			write <= 0;
			case (state)
			WAIT: begin
				if (valid) begin
					if (byte_recv == 1) begin
						index_word <= 0;
						state <= COUNT;
					end
				end
			end
			COUNT: begin
				if (valid) begin
					count <= {byte_recv, count[31:8]};
					index_word <= index_word + 1;
					if (index_word == 3) begin
						index <= 0;
						index_word <= 0;
						state <= READ;
					end
				end
			end
			READ: begin
				if (valid) begin
					buffer[index][index_word] <= byte_recv;
					index_word <= index_word + 1;
					if (index_word == 3) begin
						index <= index + 1;
						if (index == (count-1)) begin
							state <= FLAG;
						end
					end
				end
			end
			FLAG: begin
				if (~busy && ~write) begin
					write <= 1'b1;
					byte_send <= 1'b1;
					index_word <= 0;
					count_buf <= count;
					state <= PREP;
				end
			end
			PREP: begin
				if (~busy && ~write) begin
					write <= 1'b1;
					{count_buf, byte_send} <= {8'b0, count_buf};
					index_word <= index_word + 1;
					if (index_word == 3) begin
						index_word <= 0;
						index <= 0;
						state <= WRITE;
					end
				end
			end
			WRITE: begin
				if (~busy && ~write) begin
					write <= 1'b1;
					byte_send <= buffer[index][index_word];
					index_word <= index_word + 1;
					if (index_word == 3) begin
						index <= index + 1;
						if (index == (count-1)) begin
							state <= WAIT;
						end
					end
				end
			end
			endcase
		end
	
	
endmodule : example_processor