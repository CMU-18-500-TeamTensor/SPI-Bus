`default_nettype none

module testbench;

logic sclk, ss, miso, mosi, rst_L;

logic [7:0] outbuf;
logic [7:0] recv;
logic read;

logic ready_in;
logic [7:0] buffer_in;

assign mosi = miso; // link to self

task sendrecv ();
    ss <= 1;
  for (int i = 0; i < 8; i++) begin
    @(posedge sclk);
    ss <= 0;
  end
endtask

initial begin
  sclk = 0;
  rst_L = 0;
  rst_L <= 1;
  forever #5 sclk = ~sclk;
end

initial begin
  ss = 0;
end
  

SPI_slave_full spi(.*);

initial begin
  @(posedge sclk);
  @(posedge sclk);
  outbuf = 8'hA5;
  sendrecv();
  outbuf = 8'h5A;
  sendrecv();
  outbuf = 8'hAA;
  sendrecv();
  outbuf = 8'hCC;
  sendrecv();
  outbuf = 8'h0F;
  sendrecv();
  outbuf = 8'hF0;
  sendrecv();
  @(posedge sclk);
  @(posedge sclk);
  @(posedge sclk) $finish;

end



always_ff @(posedge ready_in)
  recv <= buffer_in;

endmodule : testbench