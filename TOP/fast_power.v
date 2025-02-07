//-----------------------------------------------------------------------------
// fast_power.v
//
// This module implements exponentiation by squaring for positive exponents.
// It supports both 32–bit floating point (single precision) and 64–bit
// floating point (double precision) numbers. The parameter "double" selects
// precision: 0 for single (32–bit) and 1 for double (64–bit).
//
// The design instantiates a working multiplier module, fpu_multiply,
// which is assumed to be used as shown in the instantiation example:
//
//   fpu_multiply #(.double(0)) mult_inst1 (
//       .a(a),
//       .b(b),
//       .result(bc)
//   );
//
// Negative exponents are not handled.
//-----------------------------------------------------------------------------
module fast_power #(
    parameter double = 0,
    // WIDTH is set to 32 when double==0 and 64 when double==1.
    parameter WIDTH = (double == 1) ? 64 : 32
)(
    input                   clk,
    input                   rst,
    input                   start,
    input      [WIDTH-1:0]  base,
    input      [31:0]       exponent,  // assumed nonnegative
    output reg [WIDTH-1:0]  result,
    output reg              done
);

  //-------------------------------------------------------------------------
  // Constant for the value 1.0 in IEEE-754 format.
  //-------------------------------------------------------------------------
  localparam ONE = (double == 1) ? 64'h3ff0000000000000 : 32'h3f800000;

  //-------------------------------------------------------------------------
  // State Machine Definitions
  //-------------------------------------------------------------------------
  localparam STATE_IDLE = 2'd0;
  localparam STATE_INIT = 2'd1;
  localparam STATE_CALC = 2'd2;
  localparam STATE_DONE = 2'd3;

  reg [1:0] state;

  // Internal registers to hold the current base, the accumulated result,
  // and the remaining (positive) exponent.
  reg [WIDTH-1:0] base_reg;
  reg [WIDTH-1:0] result_reg;
  reg [31:0]      exp_reg;

  //-------------------------------------------------------------------------
  // Combinational multiplier outputs
  //
  // Two instances of the fpu_multiply are used:
  //   - One computes the square of the current base.
  //   - The other computes the product (result * base) for cases when
  //     the current exponent bit is 1.
  //-------------------------------------------------------------------------
  wire [WIDTH-1:0] base_square;
  wire [WIDTH-1:0] result_mult;

  fpu_multiply #(.double(double)) mult_inst_base (
      .a(base_reg),
      .b(base_reg),
      .result(base_square)
  );

  fpu_multiply #(.double(double)) mult_inst_result (
      .a(result_reg),
      .b(base_reg),
      .result(result_mult)
  );

  //-------------------------------------------------------------------------
  // Main state machine: On reset, the module waits for a start signal.
  // On start, it initializes registers and then iterates:
  //    if (exp_reg[0] == 1) result_reg = result_reg * base_reg;
  //    base_reg = base_reg * base_reg;
  //    exp_reg = exp_reg >> 1;
  // When the exponent becomes 0, the final result is output.
  //-------------------------------------------------------------------------
  always @(posedge clk) begin
    if (rst) begin
      state      <= STATE_IDLE;
      done       <= 1'b0;
      base_reg   <= {WIDTH{1'b0}};
      result_reg <= {WIDTH{1'b0}};
      exp_reg    <= 32'd0;
      result     <= {WIDTH{1'b0}};
    end else begin
      case (state)
        //----- STATE_IDLE --------------------------------------------------
        STATE_IDLE: begin
          done <= 1'b0;
          if (start)
            state <= STATE_INIT;
        end

        //----- STATE_INIT --------------------------------------------------
        STATE_INIT: begin
          // Initialize the registers.
          base_reg   <= base;
          result_reg <= ONE;
          exp_reg    <= exponent;
          state      <= STATE_CALC;
        end

        //----- STATE_CALC --------------------------------------------------
        STATE_CALC: begin
          if (exp_reg == 0) begin
            state <= STATE_DONE;
          end else begin
            // If the least–significant bit of the exponent is 1,
            // update the accumulated result.
            if (exp_reg[0])
              result_reg <= result_mult;
            // Always square the base.
            base_reg <= base_square;
            // Shift the exponent right by one.
            exp_reg <= exp_reg >> 1;
            // Remain in STATE_CALC for the next iteration.
            state <= STATE_CALC;
          end
        end

        //----- STATE_DONE --------------------------------------------------
        STATE_DONE: begin
          result <= result_reg;
          done   <= 1'b1;
          // Remain in DONE until start is deasserted.
          if (!start) begin
            state <= STATE_IDLE;
            done  <= 1'b0;
          end
        end

        default: state <= STATE_IDLE;
      endcase
    end
  end

endmodule
