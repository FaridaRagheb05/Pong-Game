module top(
    input clk,              // 100MHz
    input reset,            // btnR
    input [1:0] btn,        // btnD, btnU
    input [1:0] btn1,
    output hsync,           // to VGA Connector
    output vsync,           // to VGA Connector
    output [11:0] rgb,       // to DAC, to VGA Connector
    output[6:0] segment,
    output[3:0] Anode
    );
    
    // state declarations for 4 states
    parameter newgame = 2'b00;
    parameter play    = 2'b01;
    parameter newball = 2'b10;
    parameter over    = 2'b11;
           
        
    // signal declaration
    reg [1:0] state_reg, state_next;
    wire [9:0] w_x, w_y;
    wire w_vid_on, w_p_tick, graph_on, hit, miss;
    wire  text_on;
    wire [11:0] graph_rgb, text_rgb;
    reg [11:0] rgb_reg, rgb_next;
    wire[6:0] score1, score2;
    wire [3:0] dig0, dig1, dig2, dig3;
    reg gra_still, d1_inc,d2_inc, d_clr, timer_start;
    wire timer_tick, timer_up;
    reg [1:0] ball_reg, ball_next;
    
    
    // Module Instantiations
    vga_controller2 vga_unit(
        .clk_100MHz(clk),
        .reset(reset),
        .video_on(w_vid_on),
        .hsync(hsync),
        .vsync(vsync),
        .p_tick(w_p_tick),
        .x(w_x),
        .y(w_y));
    
    pong_text text_unit(
        .clk(clk),
        .x(w_x),
        .y(w_y),
        .dig0(dig0),
        .dig1(dig1),
        .dig2(dig2),
        .dig3(dig3),
        .text_on(text_on),
        .text_rgb(text_rgb));
        
    pong_graphics graph_unit(
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .btn1(btn1),
        .gra_still(gra_still),
        .video_on(w_vid_on),
        .x(w_x),
        .y(w_y),
        .missRight(missRight),
        .missLeft(missLeft),
        .graph_on(graph_on),
        .graph_rgb(graph_rgb));
    
    // 60 Hz tick when screen is refreshed
//    assign timer_tick = (w_x == 0) && (w_y == 0);
//    timer timer_unit(
//        .clk(clk),
//        .reset(reset),
//        .timer_tick(timer_tick),
//        .timer_start(timer_start),
//        .timer_up(timer_up));
    
    newcounter counter_unit(
        .clk(clk),
        .reset(d_clr),
        .en(1'b1),
        .inc(d1_inc),
        .count(score1));    
        
    newcounter counter_unit1(
    .clk(clk),
    .reset(d_clr),
    .en(1'b1),
    .inc(d2_inc),
    .count(score2));
    
    wire clk200hz;
   clock_divider #(250000) clkdive(clk, reset,clk200hz );
    wire [1:0] togle;
    counter_x_bit#(2,4) counter_unit2(clk200hz, reset,1'b1,togle);
    
    wire[3:0] dig0 ,dig1,dig2,dig3;
    assign dig1 = score2 %10;
    assign dig0 = score2 /10;
    assign dig3 = score1 %10;
    assign dig2 = score1 /10;
    
    bcd gg(clk200hz, reset, togle, dig0 ,dig1,dig2,dig3,segment,Anode);
        
    // FSMD state and registers
    always @(posedge clk or posedge reset)
        if(reset) begin
            state_reg <= newgame;
            rgb_reg <= 0;
        end
    
        else begin
            state_reg <= state_next;
            if(w_p_tick)
                rgb_reg <= rgb_next;
        end
    
    // FSMD next state logic
    always @* begin
        gra_still = 1'b1;
        d1_inc = 1'b0;
        d2_inc = 1'b0;
        d_clr = 1'b0;
        state_next = state_reg;
        
        case(state_reg)
            newgame: begin
                ball_next = 2'b11;          // three balls
                d_clr = 1'b1;               // clear score
                
                if((btn|btn1) != 2'b00) begin      // button pressed
                    state_next = play;
                end
            end
            
            play: begin
                gra_still = 1'b0;   // animated screen

              
                if(missLeft) begin
                    d2_inc =1'b1;
                    state_next = newball;
                end
                else if(missRight)begin
                    d1_inc =1'b1;
                    state_next = newball;
                end
            end
            
            newball: // wait for 2 sec and until button pressed
            if(  (btn|btn1) != 1'b00)
                state_next = play;
                
            over:   // wait 2 sec to display game over
                    state_next = newgame;
        endcase           
    end
    
    // rgb multiplexing
    always @*
        if(~w_vid_on)
            rgb_next = 12'h000; // blank
        
        else

            
            if(graph_on)
                rgb_next = graph_rgb;   // colors in graph_text
           else if(text_on)
                rgb_next = text_rgb;    // colors in pong_text//            else if(text_on[2])
//                rgb_next = text_rgb;    // colors in pong_text
                
            else
                rgb_next = 12'hF00;     // aqua background
    
    // output
    assign rgb = rgb_reg;
    
endmodule