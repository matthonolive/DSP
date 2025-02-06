module comp_add #(parameter
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

  fpu_add #(.double(double)) real (
        .a(a[2*size-1:size]),
        .b(b[2*size-1:size]),
        .result(r)
      );

  fpu_add #(.double(double)) complex (
        .a(a[size-1:0]),
        .b(b[size-1:0]),
        .result(q)
      );

  assign result = {r,q};

endmodule
