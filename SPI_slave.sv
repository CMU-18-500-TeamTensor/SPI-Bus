`default_nettype none

module SPI_slave_full (
  input  logic rst_L,
  input  logic sclk, ss, mosi,
  input  logic [7:0] outbuf,
  output logic read,
  output logic ready_in,
  output logic [7:0] buffer_in,
  output logic miso);
  
logic [2:0] count;
logic [7:0] buffer;
logic start;
assign miso = buffer[7];
  
always_ff @(posedge sclk, negedge rst_L)
  if (~rst_L) begin
    start <= 1'b0;
    read <= 1'b0;
    ready_in <= 1'b0;
    buffer <= 1'b0;
    count <= 1'b0;
  end else begin
    read <= 1'b0;
    ready_in <= 1'b0;
    if (start) begin
      count <= count + 1;
      buffer <= {buffer[6:0], mosi};
      if (count == 3'b111) begin
        ready_in <= 1'b1;
        buffer_in <= {buffer[6:0], mosi};
        start <= 1'b0;
      end
    end else begin
      count <= 3'b000;
    end
    if (ss) begin
      start <= 1'b1;
      buffer <= outbuf;
      read <= 1'b1;
    end
  end
  
endmodule : SPI_slave_full