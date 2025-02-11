`timescale 1ns/1ps

module tb_twiddle;

  // Parameter to select single (0) or double (1) precision
  parameter double = 0;
  // Define the bit-width based on precision.
  localparam size = (double == 0) ? 32 : 64;

  // Declare the input and output signals.
  // theta is the input floating-point value.
  reg  [size-1:0] theta;
  // result is the module output (width = 2*size).
  wire [(2*size)-1:0] result;

  // Instantiate the DUT (Device Under Test)
  twiddle #(.double(double)) dut (
    .theta(theta),
    .result(result)
  );

  // Optional: Monitor changes to signals.
  initial begin
    $monitor("Time = %0t | theta = 0x%h | result = 0x%h", $time, theta, result);
  end

  // Stimulus block
  initial begin
    // Dump waveform data for viewing (if using a waveform viewer)
    $dumpfile("twiddle_tb.vcd");
    $dumpvars(0, tb_twiddle);

    //--- Test Case 1 ---
    // Use 1.0 as the initial value.
    // In IEEE-754 single precision, 1.0 is 32'h3f800000;
    // In double precision, 1.0 is 64'h3ff0000000000000.
    theta = (double == 0) ? 32'h3f800000 : 64'h3ff0000000000000;
    #10;

    //--- Test Case 2 ---
    // Change theta to 2.0.
    // For single precision, 2.0 is 32'h40000000;
    // For double precision, 2.0 is 64'h4000000000000000.
    theta = (double == 0) ? 32'h40000000 : 64'h4000000000000000;
    #10;

    //--- Test Case 3 ---
    // Change theta to 0.5.
    // For single precision, 0.5 is 32'h3f000000;
    // For double precision, 0.5 is 64'h3fe0000000000000.
    theta = (double == 0) ? 32'h3f000000 : 64'h3fe0000000000000;
    #10;

    // End simulation
    $finish;
  end

endmodule
