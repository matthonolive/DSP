`timescale 1ns/1ps

module tb_fpu_multiply;

  // For single precision, the parameter double==0 gives a 32-bit wide design.
  // Declare inputs as regs and outputs as wires.
  reg  [31:0] a;
  reg  [31:0] b;
  wire [31:0] result;

  // Instantiate the fpu_add module.
  // If you want to test the double precision version, change double to 1.
  fpu_multiply #(.double(0)) dut (
        .a(a),
        .b(b),
        .result(result)
      );

      initial begin
        // Setup waveform dumping for GTKWave.
        $dumpfile("fpu_multiply.vcd");
        $dumpvars(0, tb_fpu_multiply);

        // Wait a moment at the start.
        #5;

        // Test Vector 1: 1.0 * 2.0
        // In IEEE754 single precision, 1.0 is 0x3f800000.
        a = 32'h3f800000;
        b = 32'h40000000;
        #10;

        a = 32'h40400000;
        b = 32'h40000000;
        #10;

        a = 32'h40400000;
        b = 32'h00000000;
        #10;




        // End simulation.
        $finish;
      end

endmodule
