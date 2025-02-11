module twiddle #(parameter
  double = 0
)(
  theta,
  result
);

  localparam  size = (double == 0 ? 32 : 64);

  input [size-1: 0] theta;
  output [(2*size -1): 0] result;

  wire [size - 1:0] one;
  wire [size-1:0] p2;
  wire [size-1:0] p3;
  wire [size-1:0] p4;
  wire [size-1:0] p5;
  wire [size-1:0] p6;
  wire [size-1:0] p7;

  assign one = (double == 0)  ? 32'h3f800000 : 64'h3ff0000000000000;
  assign p2  = (double == 0)  ? 32'h3f000000 : 64'h3fe0000000000000;
  assign p3  = (double == 0)  ? 32'h3e2aaaab : 64'h3fc555555c7dda4b;
  assign p4  = (double == 0)  ? 32'h3d2aaaab : 64'h3fa55555559ea255;
  assign p5  = (double == 0)  ? 32'h3c088889 : 64'h3f81111127f920f1;
  assign p6  = (double == 0)  ? 32'h3ab60b61 : 64'h3f56c16c19cf4c13;
  assign p7  = (double == 0)  ? 32'h39500d16 : 64'h3f2a01a2b1342ecb;

  wire [size -1: 0] royal;
  wire [size -1: 0] comp;

  wire [size-1:0] theta_int [1:7];

  // The 1st power is the input value itself.
  assign theta_int[1] = theta;

  // Use a generate loop to instantiate 6 multipliers.
  // Each multiplier computes theta_int[i+1] = theta_int[i] * theta.
  genvar i;
  generate
    for (i = 1; i < 7; i = i + 1) begin : power_loop
      fpu_multiply #(.double(double)) mult_inst (
          .a(theta_int[i]),
          .b(theta),
          .result(theta_int[i+1])
      );
    end
  endgenerate

  wire [size-1:0] cos_t1;
  wire [size-1:0] cos_t2;
  wire [size-1:0] cos_t3;
  wire [size-1:0] cos_t4;

  assign cos_t1 = one;

  fpu_multiply #(.double(double)) cos_inst2 (
      .a(theta_int[2]),
      .b(p2),
      .result(cos_t2)
  );
  fpu_multiply #(.double(double)) cos_inst3 (
      .a(theta_int[4]),
      .b(p4),
      .result(cos_t3)
  );
  fpu_multiply #(.double(double)) cos_inst4 (
      .a(theta_int[6]),
      .b(p6),
      .result(cos_t4)
  );

  wire [size-1:0] ad1;
  wire [size-1:0] ad2;

  fpu_add #(.double(double)) cos_ad1 (
        .a(cos_t1),
        .b({1'b1, cos_t2[size-2:0]}),
        .result(ad1)
      );
  fpu_add #(.double(double)) cos_ad2 (
        .a(cos_t3),
        .b({1'b1, cos_t4[size-2:0]}),
        .result(ad2)
      );
  fpu_add #(.double(double)) cos_ad3 (
        .a(ad1),
        .b(ad2),
        .result(royal)
      );

  wire [size-1:0] sin_t1;
  wire [size-1:0] sin_t2;
  wire [size-1:0] sin_t3;
  wire [size-1:0] sin_t4;

  assign sin_t1 = theta_int[1];

  fpu_multiply #(.double(double)) sin_inst2 (
      .a(theta_int[3]),
      .b(p3),
      .result(sin_t2)
  );
  fpu_multiply #(.double(double)) sin_inst3 (
      .a(theta_int[5]),
      .b(p5),
      .result(sin_t3)
  );
  fpu_multiply #(.double(double)) sin_inst4 (
      .a(theta_int[7]),
      .b(p7),
      .result(sin_t4)
  );

  wire [size-1:0] add1;
  wire [size-1:0] add2;

  fpu_add #(.double(double)) sin_ad1 (
        .a(sin_t1),
        .b({1'b1, sin_t2[size-2:0]}),
        .result(add1)
      );
  fpu_add #(.double(double)) sin_ad2 (
        .a(sin_t3),
        .b({1'b1, sin_t4[size-2:0]}),
        .result(add2)
      );
  fpu_add #(.double(double)) sin_ad3 (
        .a(add1),
        .b(add2),
        .result(comp)
      );


  assign result = {royal, comp};


endmodule
