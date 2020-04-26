`default_nettype none

`include "memory/mem_handle.vh"

module cmd_out (
	input  logic clk, rst_L,
	input  logic cmd_send,
	mem_handle   mem_out,
	input  logic busy,
	output logic write,
	output logic cmd_done,
	output logic [7:0] byte_send);
	
	enum logic [1:0] {WAIT, LOAD, SEND} state, nextState;
	
	logic [3:0] [7:0] buffer;
	logic [1:0] index_buffer;
	
	always_comb
		case (state)
		WAIT: nextState = (cmd_send) ? LOAD : WAIT;
		LOAD: begin
			if (mem_out.ptr == mem_out.region_end)
				nextState = WAIT;
			else begin
				if (mem_out.done)
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
			mem_out.r_en <= 0;
		end else begin
			state <= nextState;
			// events (transient signals)
			write <= 1'b0;
			case (state)
			WAIT: begin
				cmd_done <= 1'b0;
				if (nextState == LOAD) begin
					mem_out.ptr <= mem_out.region_begin;
				end
			end
			LOAD: begin
				if (nextState == WAIT)
					cmd_done <= 1'b1;
					
				else if (nextState == LOAD && mem_out.avail)
						mem_out.r_en <= 1'b1;
						
				else if (nextState == SEND) begin
					mem_out.r_en <= 1'b0;
					index_buffer <= 2'b0;
					buffer <= mem_out.data_load;
				end
			end
			SEND: begin
				if (~busy & ~write) begin
					write <= 1'b1;
					byte_send <= buffer[index_buffer];
					index_buffer <= index_buffer + 1;
				end
				if (nextState == LOAD) begin
					mem_out.ptr <= mem_out.ptr + 1;
				end
			end
			endcase
		end
	
	
endmodule : cmd_out