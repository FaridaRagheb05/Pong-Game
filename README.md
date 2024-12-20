# Pong-Game
This project recreates the classic arcade game Pong on the Basys 3 FPGA board using Verilog HDL (Hardware Description Language). Pong is a two-player game where each player controls a paddle and competes to bounce a ball back and forth. The objective is to prevent the ball from passing the player's paddle while attempting to score points by making the opponent miss.

The game is displayed on a VGA monitor, with paddles, the ball, and the score shown in real-time. The Basys 3 FPGA board's switches and buttons are used to control the vertical movement of the paddles. The ball bounces off the paddles and the screen boundaries, and a score is updated each time a player misses the ball on the VGA monitor as well as the 7-segment display of the FPGA board.

This project involves several key components:

Paddle Control: Players use buttons or switches to move paddles up and down.
Ball Movement: The ball’s speed and direction are programmed, with bouncing behavior based on collisions with paddles and screen edges.
Collision Detection: Verilog logic handles the detection of ball-paddle and ball-wall collisions.
Score Tracking: A score counter keeps track of each player's score, displayed on the 7-segment displays of the Basys 3 board.
VGA Output: The game is visualized on a VGA monitor, showing the game elements in real-time.
This project not only demonstrates how to implement a simple video game on FPGA but also reinforces concepts such as digital circuit design, hardware programming, and interaction between software and hardware.
