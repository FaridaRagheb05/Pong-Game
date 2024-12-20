`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2024 01:18:37 PM
// Design Name: 
// Module Name: newcounter
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


module newcounter#(parameter x = 7, n = 100)
   (input clk, reset, en,inc, output reg [x-1:0] count);
    always @(posedge clk, posedge reset) begin
     if (reset == 1)
     count <= 0;
      else if (en == 1'b1)
           if(inc)
             if (count == n-1)
                count <= 0;
             else
             count <= count + 1;
     
    end
endmodule
