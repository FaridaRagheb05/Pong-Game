`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2024 10:12:44 AM
// Design Name: 
// Module Name: counter_x_bit
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module counter_x_bit #(parameter x = 3, n = 6)
   (input clk, reset, en, output reg [x-1:0] count);
always @(posedge clk, posedge reset) begin
 if (reset == 1)
 count <= 0;
  else if (en == 1'b1)
         if (count == n-1)
         count <= 0;
         else
         count <= count + 1;
 
end
endmodule