`timescale 1ns/1ps

module tb_comp_multiply;

  // For single precision, the parameter double==0 gives a 32-bit wide design.
  // Declare inputs as regs and outputs as wires.
  reg  [63:0] a;
  reg  [63:0] b;
  wire [63:0] result;

  // Instantiate the fpu_add module.
  // If you want to test the double precision version, change double to 1.
  comp_multiply #(.double(0)) dut (
    .a(a),
    .b(b),
    .result(result)
  );

  initial begin
    // Setup waveform dumping for GTKWave.
    $dumpfile("comp_multiply.vcd");
    $dumpvars(0, tb_comp_multiply);

    // Wait a moment at the start.
    #5;

    // Test Vector 1: 1.0 + 0
    // In IEEE754 single precision, 1.0 is 0x3f800000.
    a = 64'h3dcccccd3dcccccd; //0.1 + 0.1i
    b = 64'h3dcccccd3dcccccd; //0.1 + 0.1i
    #10;


    // End simulation.
    $finish;
  end
endmodule
