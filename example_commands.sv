`default_nettype none

module example_commands (
	input  logic clk, rst_L,
	input  logic cmd_done,
	input  logic cmd_ready,
	mem_handle   cmd_in,
	output logic cmd_send,
	mem_handle   cmd_out);

	logic [15:0][31:0] buffer;
	logic [3:0] index;
	
	enum logic [1:0] {WAIT, IN, OUT} state, nextState;
	
	assign cmd_out.region_begin = 0; 
	
	always_comb begin
		case (state)
			WAIT: nextState = (cmd_ready) ? IN : WAIT;
			IN: nextState = (cmd_in.done && index == cmd_in.region_end) ? OUT : IN;
			OUT: nextState = (cmd_done) ? WAIT : OUT;
			default: nextState = WAIT;
		endcase
	end
	
	
	always_ff @(posedge clk, negedge rst_L)
		if (~rst_L) begin
			state <= WAIT;
			buffer <= 0;
			index <= 0;
			cmd_send <= 0;
			cmd_out.region_end <= 0;
			cmd_out.data_load <= 0;
			cmd_out.done <= 0;
		
		end else begin
			state <= nextState;
			// event (transient signals)
			cmd_send <= 1'b0;
			cmd_out.done <= 1'b0;
			case (state)
			WAIT: begin
				if (nextState == IN) begin
					index <= 0;
					// cmd_in.ptr <= 0; // Unused, read buffer automatically changes
					cmd_in.r_en <= 1'b1;
				end
			end
			IN: begin
				if ((nextState == IN) && ~cmd_in.r_en && ~cmd_in.done) begin
					cmd_in.r_en <= 1'b1;
				end
				if (cmd_in.r_en && cmd_in.done) begin
					cmd_in.r_en <= 1'b0;
					buffer[index] <= cmd_in.data_load;
					index <= index + 1;
					// cmd_in.ptr <= cmd_in.ptr + 1; // Unused, see above.
				end
				if (nextState == OUT) begin
					index <= 0;
					cmd_out.region_end <= cmd_in.region_end;
					cmd_out.data_load <= 0;
					cmd_send <= 1'b1;
				end
			end
			OUT: begin
				if (cmd_out.r_en && ~cmd_out.done) begin
					cmd_out.data_load <= buffer[cmd_out.ptr];
					cmd_out.done <= 1'b1;
				end
			end
			endcase
		end
	

endmodule : example_commands