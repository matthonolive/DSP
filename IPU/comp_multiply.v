module comp_multiply #(parameter
  double = 0
)(
  a,
  b,
  result
);
  localparam  size = (double == 0 ? 32 : 64);

  input [(2*size - 1): 0] a;
  input [(2*size - 1): 0] b;
  output [(2*size -1): 0] result;

  wire [size-1:0] r;
  wire [size-1:0] q;
  wire [size-1:0] ac;
  wire [size-1:0] bc;
  wire [size-1:0] da;
  wire [size-1:0] bd;


  fpu_multiply #(.double(double)) mult_inst1 (
        .a(a[2*size-1:size]),
        .b(b[2*size-1:size]),
        .result(ac)
      );
  fpu_multiply #(.double(double)) mult_inst2 (
        .a(a[size-1:0]),
        .b(b[2*size-1:size]),
        .result(bc)
      );
  fpu_multiply #(.double(double)) mult_inst3 (
        .a(a[2*size-1:size]),
        .b(b[size-1:0]),
        .result(da)
      );
  fpu_multiply #(.double(double)) mult_inst4 (
        .a(a[size-1:0]),
        .b(b[size-1:0]),
        .result(bd)
      );

  fpu_add #(.double(double)) real_inst (
        .a(ac),
        .b({1'b1, bd[size-2:0]}),
        .result(r)
      );

  fpu_add #(.double(double)) complex_inst (
        .a(bc),
        .b(da),
        .result(q)
      );

  assign result = {r,q};

endmodule
