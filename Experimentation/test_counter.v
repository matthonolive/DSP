module test_counter(input clk, input reset, output reg [7:0] counter);
  always @(posedge clk or posedge reset) begin
    if (reset)
      counter <= 0;
    else
      counter <= counter + 1;
  end
endmodule
