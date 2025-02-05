`timescale 1ns/1ps
module tb_test_counter;
  reg clk;
  reg reset;
  wire [7:0] counter;

  test_counter uut (
    .clk (clk),
    .reset(reset),
    .counter(counter)
  );

  initial clk = 0;
  always #5 clk = ~clk;

  initial begin
    reset = 1;
    #20;
    reset = 0;
    #200;
    $finish;
  end

  initial begin
    $dumpfile("waveform.vcd");
    $dumpvars(0, tb_test_counter);
  end
endmodule
