`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:54:05 05/28/2015
// Design Name:   Butterfly_Radix2
// Module Name:   Butterfly_Radix2_tb.v
// Project Name:  FFT_20150521
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: Butterfly_Radix2
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module Butterfly_Radix2_tb;

 // The width of the input, output and twiddle factors.
 parameter DataWidth = 16;

	// Inputs
	reg [DataWidth-1:0] X0_Re;
	reg [DataWidth-1:0] X0_Im;
	reg [DataWidth-1:0] X1_Re;
	reg [DataWidth-1:0] X1_Im;

	// Outputs
	wire [DataWidth-1:0] Y0_Re;
	wire [DataWidth-1:0] Y0_Im;
	wire [DataWidth-1:0] Y1_Re;
	wire [DataWidth-1:0] Y1_Im;

	// Instantiate the Unit Under Test (UUT)
	Butterfly_Radix2 uut (
		.X0_Re(X0_Re), 
		.X0_Im(X0_Im), 
		.X1_Re(X1_Re), 
		.X1_Im(X1_Im), 
		.Y0_Re(Y0_Re), 
		.Y0_Im(Y0_Im), 
		.Y1_Re(Y1_Re), 
		.Y1_Im(Y1_Im)
	);
	
reg clk = 0;
	
always 	
# 10 clk <= ~clk;

	initial begin
		// Initialize Inputs
		X0_Re = 0;
		X0_Im = 0;
		X1_Re = 0;
		X1_Im = 0;

		// Wait 100 ns for global reset to finish
		#10;
      X0_Re = 100;
		X0_Im = 0;
		X1_Re = 700;
		X1_Im = 0;  

	end
      
endmodule

