`default_nettype none

module spi_to_fpga (
	input  logic clk, sclk, rst_L,
	input  logic [7:0] buffer_in,
	input  logic sendrecv,
	output logic valid,
	output logic [7:0] buffer_out);
	
	logic spi_delay, spi_req, req_ack, cross_tmp, fin_ack;
	logic [7:0] buffer;
	
	logic busy;
	assign busy = fin_ack || spi_delay;
	
	always_ff @(posedge sclk, negedge rst_L)
		if (~rst_L) begin
			spi_delay <= 0;
			spi_req <= 0;
			cross_tmp <= 0;
			buffer <= 0;
		end else begin
			{fin_ack, cross_tmp} <= {cross_tmp, req_ack};
			if (~busy) begin
				if (sendrecv) begin
					buffer <= buffer_in;
					spi_delay <= 1'b1;
				end
			end 
			if (spi_delay) begin
				spi_req <= 1'b1;
			end
			if (fin_ack) begin
				spi_delay <= 1'b0;
				spi_req <= 1'b0;
			end
		end
		
	always_ff @(posedge clk, negedge rst_L)
		if (~rst_L) begin
			req_ack <= 0;
			valid <= 0;
			buffer_out <= 0;
		end else begin
			valid <= 1'b0;
			if (~req_ack && spi_req) begin
				buffer_out <= buffer;
				valid <= 1'b1;
				req_ack <= 1'b1;
			end
			if (~spi_req)
				req_ack <= 1'b0;
		end
	
endmodule : spi_to_fpga


// SPI module will pause ack until it's free
module fpga_to_spi (
	input  logic clk, sclk, rst_L,
	input  logic [7:0] buffer_in,
	input  logic sendrecv,
	input  logic write,
	output logic busy,
	output logic [7:0] buffer_out);

	logic [7:0] buffer;
	logic spi_full;
	logic busy_delay, busy_ack, spi_ack, cross_tmp, fin_ack;
	
	assign busy = fin_ack || busy_delay;
	
	always_ff @(posedge clk, negedge rst_L)
		if (~rst_L) begin
			busy_delay <= 0;
			busy_ack <= 0;
			cross_tmp <= 0;
			fin_ack <= 0;
			buffer <= 0;
		end else begin
			{fin_ack, cross_tmp} <= {cross_tmp, spi_ack};
			if (~busy) begin
				if (write) begin
					busy_delay <= 1'b1;
					buffer <= buffer_in;
				end
			end
			if (busy_delay)
				busy_ack <= 1'b1;
			if (fin_ack) begin
				busy_delay <= 1'b1;
				busy_ack <= 1'b1;
			end
		end
	
	always_ff @(posedge sclk, negedge rst_L)
		if (~rst_L) begin
			spi_ack <= 0;
			buffer_out <= 0;
			spi_full <= 0;
		end else begin
			if (sendrecv) begin
				spi_full <= 1'b0;
				buffer_out <= 0;
			end else if (busy_ack && ~spi_full) begin
				spi_full <= 1'b1;
				buffer_out <= buffer;
				spi_ack <= 1'b1;
			end
			if (~busy_ack) 
				spi_ack <= 1'b0;
			
		end
	
endmodule : fpga_to_spi