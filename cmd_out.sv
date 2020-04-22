`default_nettype none

module responder (
	input  logic clk, rst_L,
	input  logic cmd_ready,
	mem_handle   request_mem,
	input  logic busy,
	output logic write,
	output logic cmd_done,
	output logic [7:0] byte_send);
	
	enum logic [1:0] {WAIT, LOAD, SEND} state, nextState;
	
	logic [3:0] [7:0] buffer;
	logic [1:0] index_buffer;
	
	always_comb
		case (state)
		WAIT: nextState = (cmd_ready) ? LOAD : WAIT;
		LOAD: begin
			if (request_mem.ptr == request_mem.region_end)
				nextState = WAIT;
			else begin
				if (request_mem.done)
					nextState = SEND;
				else
					nextState = LOAD;
			end
		end
		SEND: nextState = (index_buffer == 3) ? LOAD : SEND;
		endcase
	
	always_ff @(posedge clk, negedge rst_L)
		if (~rst_L) begin
			state <= WAIT;
			buffer <= 0;
			index_buffer <= 0;
			write <= 0;
			cmd_done <= 0;
			byte_send <= 0;
			request_mem.r_en <= 0;
		end else begin
			state <= nextState;
			case (state)
			WAIT: begin
				cmd_done <= 1'b0;
				if (nextState == LOAD) begin
					request_mem.ptr <= request_mem.region_begin;
				end
			end
			LOAD: begin
				if (nextState == WAIT)
					cmd_done <= 1'b1;
					
				else if (nextState == LOAD && request_mem.avail)
						request_mem.r_en <= 1'b1;
						
				else if (nextState == SEND) begin
					request_mem.r_en <= 1'b0;
					index_buffer <= 2'b0;
					buffer <= request_mem.data_load;
				end
			end
			SEND: begin
				write <= 1'b0;
				if (~busy & ~write) begin
					write <= 1'b1;
					byte_send <= buffer[index_buffer];
					index_buffer <= index_buffer + 1;
				end
				if (nextState == LOAD) begin
					request_mem.ptr <= request_mem.ptr + 1;
				end
				end
			end
			endcase
		end
	
	
endmodule : responder