`default_nettype none

module testbench;

logic sclk, ss, miso, mosi, rst_L;

logic [7:0] outbuf;
logic sendrecv;

logic [7:0] buffer_in;

assign mosi = miso; // link to self

task send_and_set_next ();
  ss <= 0;
  for (int i = 0; i < 8; i++) begin
    @(posedge sclk);
  end
  ss <= 1;
endtask

initial begin
  sclk = 0;
  ss = 1;
  rst_L = 0;
  rst_L <= 1;
  forever #5 sclk = ~sclk;
end

SPI_slave_full spi(.*);

initial begin
  @(posedge sclk);
  @(posedge sclk);
  outbuf = 8'h5A;
  send_and_set_next();
  send_and_set_next();
  outbuf = 8'hA5;
  send_and_set_next();
  outbuf = 8'hAA;
  send_and_set_next();
  outbuf = 8'hCC;
  @(posedge sclk)
  send_and_set_next();
  outbuf = 8'h0F;
  send_and_set_next();
  outbuf = 8'hF0;
  send_and_set_next();
  @(posedge sclk);
  @(posedge sclk);
  @(posedge sclk) $finish;

end


endmodule : testbench