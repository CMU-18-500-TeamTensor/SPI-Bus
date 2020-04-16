`default_nettype none

module SPI_async (
	input  logic clk, rst_L,
	input  logic sclk, ss, mosi,
	input  logic [7:0] buffer_out,
	output logic sendrecv,
	output logic [7:0] buffer_in,
	output logic miso);

logic trigger;
logic [2:0] count;
logic [2:0] sclk_last;
logic [7:0] buffer;

assign trigger = (sclk_last[2:1] == 2'b01);


assign miso = buffer[count];

always_ff @(posedge clk, negedge rst_L)
	if (~rst_L) begin
		count <= 3'b111;
		sclk_last <= 3'b0;
		sendrecv <= 0;
		buffer <= 0;
	end else begin
		sclk_last <= {sclk_last[1:0], sclk};
		sendrecv <= 0;
		if (~ss) begin
			if (trigger) begin
				buffer_in[count] <= mosi;
				count <= count - 1;
				if (count == 3'b0) begin
					sendrecv <= 1'b1;
					buffer <= buffer_out;
				end
			end
		end
	end


endmodule : SPI_async