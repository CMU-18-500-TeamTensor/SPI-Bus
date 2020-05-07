`default_nettype none

`include "memory/mem_handle.vh"

module cmd_in (
	input  logic clk, rst_L,
	input  logic [7:0] byte_recv,
	input  logic valid,
	mem_handle   cmd_scratch,
	output logic cmd_ready);
	
	enum logic [1:0] {WAIT, COUNT, READ} state, nextState;

	logic [3:0][7:0] buffer;
	logic [31:0] count_next, count_tmp;
	logic [1:0] index_word;
	logic [`ADDR_SIZE-1:0] index, count;
	
	assign count_next = {byte_recv, count_tmp[31:8]};
	assign count = count_next[`ADDR_SIZE-1:0];
	assign cmd_scratch.region_begin = 0;
	
	
	always_comb
		case (state)
			WAIT: nextState = (valid && (byte_recv == 8'd1)) ? COUNT : WAIT;
			COUNT: nextState = (valid && (index_word == 3)) ? READ : COUNT;
			READ: nextState = (index == cmd_scratch.region_end) ? WAIT : READ;
			default: nextState = WAIT;
		endcase
	
	always_ff @(posedge clk, negedge rst_L)
		if (~rst_L) begin
			cmd_ready <= 0;
			cmd_scratch.done <= 0;
			index_word <= 0;
			count_tmp <= 0;
			state <= WAIT;
		end else begin
			state <= nextState;
			// events (transient signals)
			cmd_ready <= 0;
			cmd_scratch.done <= 0;
			case (state)
			WAIT: begin
				if (nextState == COUNT) begin
					index_word <= 0;
				end
			end
			COUNT: begin
				if (valid) begin
					count_tmp <= count_next;
					index_word <= index_word + 1;
				end
				if (nextState == READ) begin
					index <= 0;
					index_word <= 0;
					cmd_ready <= 1;
					cmd_scratch.region_end <= count;
					state <= READ;
				end
			end
			READ: begin
				if (valid) begin
					buffer[index_word] <= byte_recv;
					index_word <= index_word + 1;
					if (index_word == 3) begin
						index <= index + 1;
						cmd_scratch.data_load <= {byte_recv, buffer[2:0]};
						cmd_scratch.done <= 1'b1;
					end
				end
			end
			endcase
		end
	
endmodule : cmd_in