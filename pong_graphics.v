`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/08/2024 06:32:41 AM
// Design Name: 
// Module Name: pong_graphics
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


module pong_graphics(
    input clk,  
    input reset,    
    input [1:0] btn,        // btn[0] = up, btn[1] = down
    input [1:0] btn1,
    input gra_still,        // still graphics - newgame, game over states
    input video_on,
    input [9:0] x,
    input [9:0] y,
    output graph_on,
    output reg missLeft, missRight,   // ball hit or miss
    output reg [11:0] graph_rgb
    );
    
    // maximum x, y values in display area
    parameter X_MAX = 639;
    parameter Y_MAX = 479;
    
    // create 60Hz refresh tick
    wire refresh_tick;
    assign refresh_tick = ((y == 481) && (x == 0)) ? 1 : 0; // start of vsync(vertical retrace)
    
    

    
    
    
    // Right PADDLE
    // paddle horizontal boundaries
    parameter Right_X_PAD_L = 600;
    parameter Right_X_PAD_R = 609;    // 4 pixels wide
    // paddle vertical boundary signals
    wire [9:0] Right_y_pad_t, Right_y_pad_b;
    // register to track top boundary and buffer
    reg [9:0] Right_y_pad_reg = 204;      // Paddle starting position
    reg [9:0] Right_y_pad_next;
    // paddle moving velocity when a button is pressed
    parameter PAD_VELOCITY = 3;     // change to speed up or slow down paddle movement
    
    parameter PAD_HEIGHT = 80;
    // Left PADDLE
    // paddle horizontal boundaries
   
        // Left PADDLE
    // paddle horizontal boundaries
    parameter Left_X_PAD_L = 30;
    parameter Left_X_PAD_R = 39;    // 4 pixels wide
    // paddle vertical boundary signals
    wire [9:0] Left_y_pad_t, Left_y_pad_b;
    // register to track top boundary and buffer
    reg [9:0] Left_y_pad_reg = 204;      // Paddle starting position
    reg [9:0] Left_y_pad_next;

   
    
    
    // BALL
    // square rom boundaries
    parameter BALL_SIZE = 8;
    // ball horizontal boundary signals
    wire [9:0] x_ball_l, x_ball_r;
    // ball vertical boundary signals
    wire [9:0] y_ball_t, y_ball_b;
    // register to track top left position
    reg [9:0] y_ball_reg, x_ball_reg;
    // signals for register buffer
    wire [9:0] y_ball_next, x_ball_next;
    // registers to track ball speed and buffers
    reg [9:0] x_delta_reg, x_delta_next;
    reg [9:0] y_delta_reg, y_delta_next;
    // positive or negative ball velocity
    parameter BALL_VELOCITY_POS = 1;    // ball speed positive pixel direction(down, Left)
    parameter BALL_VELOCITY_NEG = -1;   // ball speed negative pixel direction(up, left)
    // round ball from square image
    wire [2:0] rom_addr, rom_col;   // 3-bit rom address and rom column
    reg [7:0] rom_data;             // data at current rom address
    wire rom_bit;                   // signify when rom data is 1 or 0 for ball rgb control
    
    
    // Register Control
    always @(posedge clk or posedge reset)
        if(reset) begin
            Right_y_pad_reg <= 204;
            Left_y_pad_reg <= 204;
            x_ball_reg <= X_MAX/2;
            y_ball_reg <= Y_MAX/2;
            x_delta_reg <= 10'h001;
            y_delta_reg <= 10'h001;
        end
        else begin
            Right_y_pad_reg <= Right_y_pad_next;
            Left_y_pad_reg <= Left_y_pad_next;
            x_ball_reg <= x_ball_next;
            y_ball_reg <= y_ball_next;
            x_delta_reg <= x_delta_next;
            y_delta_reg <= y_delta_next;
        end
    
    
    // ball rom
    always @*
        case(rom_addr)
            3'b000 :    rom_data = 8'b00111100; //   ****  
            3'b001 :    rom_data = 8'b01111110; //  ******
            3'b010 :    rom_data = 8'b11111111; // ********
            3'b011 :    rom_data = 8'b11111111; // ********
            3'b100 :    rom_data = 8'b11111111; // ********
            3'b101 :    rom_data = 8'b11111111; // ********
            3'b110 :    rom_data = 8'b01111110; //  ******
            3'b111 :    rom_data = 8'b00111100; //   ****
        endcase
    
    
    // OBJECT STATUS SIGNALS
    wire pad_on, sq_ball_on, ball_on;
    wire [11:0] pad_rgb, ball_rgb, bg_rgb;
    
    
    // pixel within wall boundaries

    
    
    // assign object colors
    assign pad_rgb    = 12'h0F0;    // blue paddle
    assign ball_rgb   = 12'h00F;    // red ball
    assign bg_rgb     = 12'hF00;    // aqua background
    
    
    //Right paddle 
    assign Right_y_pad_t = Right_y_pad_reg;                             // paddle top position
    assign Right_y_pad_b = Right_y_pad_t + PAD_HEIGHT - 1;              // paddle bottom position
    
    
      //Left paddle 
    assign Left_y_pad_t = Left_y_pad_reg;                             // paddle top position
    assign Left_y_pad_b = Left_y_pad_t + PAD_HEIGHT - 1;              // paddle bottom position
    
    
    
    // Pad On
    assign pad_on = (Right_X_PAD_L <= x) && (x <= Right_X_PAD_R) &&     // pixel within paddle boundaries
                    (Right_y_pad_t <= y) && (y <= Right_y_pad_b) 
                    || ((Left_X_PAD_L <= x) && (x <= Left_X_PAD_R) &&    
                    (Left_y_pad_t <= y) && (y <= Left_y_pad_b));
       
                    
    // Paddle Control
    always @* begin
        Left_y_pad_next = Left_y_pad_reg;     // no move
        Right_y_pad_next = Right_y_pad_reg;     // no move
        
        if(refresh_tick)begin
            if(btn[1] & (Left_y_pad_b < (Y_MAX - 1 - PAD_VELOCITY)))
                Left_y_pad_next = Left_y_pad_reg + PAD_VELOCITY;  // move down
            else if(btn[0] & (Left_y_pad_t > (0 + 1 + PAD_VELOCITY)))
                Left_y_pad_next = Left_y_pad_reg - PAD_VELOCITY;  // move up
                
                
                
            if(btn1[1] & (Right_y_pad_b < (Y_MAX - 1 - PAD_VELOCITY)))
                Right_y_pad_next = Right_y_pad_reg + PAD_VELOCITY;  // move down
            else if(btn1[0] & (Right_y_pad_t > (0 + 1 + PAD_VELOCITY)))
                Right_y_pad_next = Right_y_pad_reg - PAD_VELOCITY;  // move up
                
                
                
        end
                
    end
    
    
    // rom data square boundaries
    assign x_ball_l = x_ball_reg;
    assign y_ball_t = y_ball_reg;
    assign x_ball_r = x_ball_l + BALL_SIZE - 1;
    assign y_ball_b = y_ball_t + BALL_SIZE - 1;
    // pixel within rom square boundaries
    assign sq_ball_on = (x_ball_l <= x) && (x <= x_ball_r) &&
                        (y_ball_t <= y) && (y <= y_ball_b);
    // map current pixel location to rom addr/col
    assign rom_addr = y[2:0] - y_ball_t[2:0];   // 3-bit address
    assign rom_col = x[2:0] - x_ball_l[2:0];    // 3-bit column index
    assign rom_bit = rom_data[rom_col];         // 1-bit signal rom data by column
    // pixel within round ball
    assign ball_on = sq_ball_on & rom_bit;      // within square boundaries AND rom data bit == 1
 
  
    // new ball position
    assign x_ball_next = (gra_still) ? X_MAX / 2 :
                         (refresh_tick) ? x_ball_reg + x_delta_reg : x_ball_reg;
    assign y_ball_next = (gra_still) ? Y_MAX / 2 :
                         (refresh_tick) ? y_ball_reg + y_delta_reg : y_ball_reg;
    
    // change ball direction after collision
    always @* begin
        missLeft = 1'b0;
        missRight = 1'b0;
        x_delta_next = x_delta_reg;
        y_delta_next = y_delta_reg;
        
        if(gra_still) begin
            x_delta_next = BALL_VELOCITY_NEG;
            y_delta_next = BALL_VELOCITY_POS;
        end
        
        else if(y_ball_t <= 0)                   // reach top
            y_delta_next = BALL_VELOCITY_POS;   // move down
        
        else if(y_ball_b >= (Y_MAX))         // reach bottom wall
            y_delta_next = BALL_VELOCITY_NEG;   // move up
        

        
        else if((Left_X_PAD_L <= x_ball_l) && (x_ball_l <= Left_X_PAD_R) &&
                (Left_y_pad_t <= y_ball_b) && (y_ball_t <= Left_y_pad_b)) 
                    x_delta_next = BALL_VELOCITY_POS;
       
        else if((Right_X_PAD_L <= x_ball_r) && (x_ball_r <= Right_X_PAD_R) &&
        (Right_y_pad_t <= y_ball_b) && (y_ball_t <= Right_y_pad_b)) 
            x_delta_next = BALL_VELOCITY_NEG;


        else if(x_ball_r >= X_MAX)
            missRight = 1'b1;
        else if(x_ball_r <= 0)
            missLeft = 1'b1;
    
            
    end                    
    
    // output status signal for graphics 
    assign graph_on = pad_on || ball_on;
    
    
    // rgb multiplexing circuit
    always @*
        if(~video_on)
            graph_rgb = 12'h000;      // no value, blank
        else
            if(pad_on)
                graph_rgb = pad_rgb;      // paddle color
            else if(ball_on)
                graph_rgb = ball_rgb;     // ball color
            else
                graph_rgb = bg_rgb;       // module ball 
       
endmodule