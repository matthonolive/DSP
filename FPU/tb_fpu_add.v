`timescale 1ns/1ps

module tb_fpu_add;

  // For single precision, the parameter double==0 gives a 32-bit wide design.
  // Declare inputs as regs and outputs as wires.
  reg  [63:0] a;
  reg  [63:0] b;
  wire [63:0] result;

  // Instantiate the fpu_add module.
  // If you want to test the double precision version, change double to 1.
  fpu_add #(.double(1)) dut (
    .a(a),
    .b(b),
    .result(result)
  );

  initial begin
    // Setup waveform dumping for GTKWave.
    $dumpfile("fpu_add.vcd");
    $dumpvars(0, tb_fpu_add);

    // Wait a moment at the start.
    #5;

    // Test Vector 1: 1.0 + 0
    // In IEEE754 single precision, 1.0 is 0x3f800000.
    a = 64'h3ff0000000000000;
    b = 64'h0000000000000000;
    #10;

    // Test Vector 2: 2.0 + 3.0
    // 2.0 = 0x40000000, 3.0 = 0x40400000.
    a = 64'h4000000000000000;
    b = 64'h4008000000000000;
    #10;

    // Test Vector 3: -1.0 + 1.0
    // -1.0 = 0xbf800000.
    a = 64'hbff0000000000000;
    b = 64'h3ff0000000000000;
    #10;


    // End simulation.
    $finish;
  end

endmodule
