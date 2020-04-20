`default_nettype none

module ChipInterface (
	input  logic CLOCK_50, GPIO_028, GPIO_031, GPIO_032, GPIO_033,
	input  logic [7:0] byte_send,
	input  logic write,
	output logic clk, rst_L,
	output logic valid, busy,
	output logic [7:0] byte_recv,
	output logic GPIO_030,
	output logic [7:0] LED);

	logic sendrecv;
	logic sclk, ss, miso, mosi;
	logic spll, locked;
	
	assign clk = CLOCK_50;
	assign rst_L = GPIO_031;
	assign ss = GPIO_033;
	assign sclk = GPIO_032;
	assign mosi = GPIO_028;
	assign GPIO_030 = miso;
						  
	logic [7:0] buffer_in, buffer_out;
	
	assign LED = byte_recv;
	
	SPI_async spi(.clk(spll),
					  .rst_L, .sclk, .ss, .mosi,
					  .buffer_out, .sendrecv, .buffer_in,
					  .miso);
	
	spi_to_fpga recv(.clk, .sclk(spll), .rst_L,
						  .buffer_in, .sendrecv,
						  .valid, .buffer_out(byte_recv));
	
	fpga_to_spi send(.clk, .sclk(spll), .rst_L,
						  .buffer_in(byte_send),
						  .sendrecv, 
						  .write, .busy,
						  .buffer_out);
	
	sclk_pll spi_pll(.areset(~rst_L),
						  .inclk0(CLOCK_50),
						  .c0(spll),
						  .locked(locked));
						  
	/*					  
	always @(posedge spll, negedge rst_L)
		if (~rst_L) begin
			buffer_out <= 0;
		end else begin
			if (sendrecv)
				buffer_out <= buffer_in;
		end
	*/

endmodule : ChipInterface