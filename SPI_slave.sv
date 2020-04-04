`default_nettype none

module SPI_slave (
  input  logic rst_L,
  input  logic sclk, ss, mosi,
  input  logic [7:0] outbuf,
  output logic sendrecv,
  output logic [7:0] buffer_in,
  output logic miso);
  
logic [2:0] count;
logic [7:0] buffer;

assign miso = ~ss ? buffer[7] : 1'bz;
  
always_ff @(posedge sclk, negedge rst_L)
  if (~rst_L) begin
    sendrecv <= 1'b0;
    buffer_in <= 1'b0;
    buffer <= 1'b0;
    count <= 1'b0;
  end else begin
    sendrecv <= 1'b0;
    if (~ss) begin
      count <= count + 3'b001;
      buffer <= {buffer[6:0], mosi};
      if (count == 3'b111) begin
        sendrecv <= 1'b1;
        buffer_in <= {buffer[6:0], mosi};
        buffer <= outbuf;
      end
    end else begin
      count <= 3'b000;
    end
  end
  
endmodule : SPI_slave