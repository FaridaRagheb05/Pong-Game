`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2024 10:13:16 AM
// Design Name: 
// Module Name: bcd
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

module bcd(input clk ,reset,input [1:0]tog,input [3:0]dig0, dig1,dig2,dig3,output reg [0:6] segments,output reg [3:0] anode_active);
reg [3:0] num;
always @* begin

        case(num)
            0: segments = 7'b1000000;
            1: segments = 7'b1111001;
            2: segments = 7'b0100100;
            3: segments = 7'b0110000;
            4: segments = 7'b0011001;
            5: segments = 7'b0010010;
            6: segments = 7'b0000010;
            7: segments = 7'b1111000;
            8: segments = 7'b0000000;
            default: segments = 7'b0000100;

        endcase

end
always@(posedge clk or posedge reset)begin
    if(reset)begin
        num = 4'd0;
        anode_active =4'd15;
    end
    else
        case(tog)
            0:begin  anode_active = 4'b1110; num =dig2; end
            1:begin anode_active = 4'b1101; num =dig3; end
            2:begin anode_active = 4'b1011; num =dig0; end
            3:begin anode_active = 4'b0111; num =dig1; end
        endcase
end

endmodule