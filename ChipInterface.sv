`default_nettype none

module ChipInterface (
	input  logic GPIO_014, GPIO_017, GPIO_018, GPIO_019,
	output logic GPIO_016, 
	output logic [7:0] LED);

	logic [7:0] buffer;
	logic rst_L;
	logic sendrecv;
	
	logic sclk, ss, miso, mosi;
	
	logic ss_show;
	always_ff @(posedge sclk, negedge rst_L)
		if (~rst_L) begin
			ss_show <= 0;
		end else begin
			if (ss)
				ss_show <= 1'b1;
		end
	
	assign rst_L = GPIO_017;
	assign ss = GPIO_019;
	assign sclk = GPIO_018;
	assign mosi = GPIO_014;
	assign GPIO_016 = miso;
	
	assign LED = {ss_show, ss, buffer[2:0], miso, mosi, rst_L};
	
	
	SPI_slave spi(.rst_L, .sclk, .ss, .mosi,
	              .outbuf(buffer),
				     .sendrecv, 
				     .buffer_in(buffer),
				     .miso);
	

endmodule : ChipInterface