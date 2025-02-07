module twiddle #(parameter
  double = 0
)(
  theta,
  result
);

  localparam  size = (double == 0 ? 32 : 64);

  input [size-1: 0] theta;
  output [(2*size -1): 0] result;

  

endmodule
