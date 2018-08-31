`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// CreateDate: 11:49:02 05/28/2015 
//Design Name: 
// Module Name: Butterfly_Radix2 
// Project Name: 
// TargetDevices: 
// Tool versions: 
//Description: 
//
//Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module Butterfly_Radix2
//=============================================================================	
//========================= ParametersDeclarations ===========================		
//=============================================================================
#(
 // The width of the input, output and twiddle factors.
 parameter DataWidth = 16
 )
//=============================================================================
//======================== InputsDeclarations ============================
//============================================================================= 
(
input  wire  								clk, 
input  wire  								rst,
//input  wire 								Start,
//output reg								Done,
input  wire signed [DataWidth-1 	:0] X0_Re,
input  wire signed [DataWidth-1 	:0] X0_Im,
input  wire signed [DataWidth-1 	:0] X1_Re,
input  wire signed [DataWidth-1	:0] X1_Im,
input  wire signed [31				:0]  sin, 
input  wire signed [31				:0]  cos,
output wire signed [DataWidth 	:0] Y0_Re,
output wire signed [DataWidth 	:0] Y0_Im,
output reg  signed [DataWidth 	:0] Y1_Re,
output reg  signed [DataWidth 	:0] Y1_Im

);
// Double length product
//wire signed 	[DataWidth-1:0] sin, cos;
//assign sin = 0;
//assign cos = 1;
//Addition Operation
wire signed [DataWidth :0] Y0_Re_Add = X0_Re + X1_Re;//
wire signed [DataWidth :0] Y0_Im_Add = X0_Im + X1_Im;//
//Subtraction Operation
wire signed [DataWidth-1 :0] Y0_Re_Sub = X0_Re - X1_Re;//
wire signed [DataWidth-1 :0] Y0_Im_Sub = X0_Im - X1_Im;//
//Output the Addition
assign Y0_Re = Y0_Re_Add;
assign Y0_Im = Y0_Im_Add;

//Cos
wire signed [(DataWidth*2)-1 :0] Cos_Re_Mul = cos * Y0_Re_Sub;//cos_tr = cos * tr;
wire signed [(DataWidth*2)-1 :0] Cos_Im_Mul = cos * Y0_Im_Sub;//cos_ti = cos * ti; 
//Sin
wire signed [(DataWidth*2)-1 :0] Sin_Re_Mul = sin * Y0_Re_Sub;//sin_tr = sin * tr;
wire signed [(DataWidth*2)-1 :0] Sin_Im_Mul = sin * Y0_Im_Sub;//sin_ti = sin * ti;


wire    signed  [(DataWidth*2)-1:  0 ]  Y1_Re_Add_Mul = Cos_Re_Mul +  Sin_Im_Mul ; //
wire    signed  [(DataWidth*2)-1:  0 ]  Y1_Im_Add_Mul = Cos_Im_Mul -  Sin_Re_Mul ; //

//Combinational results
//assign Y1_Re = Y1_Re_Add_Mul [DataWidth - 1:0]; 
//assign Y1_Im = Y1_Im_Add_Mul [DataWidth - 1:0];

//Sequential results
always @ (posedge clk )//or negedge rst
begin
if (rst) 
	begin 
	Y1_Re <= 0; 
	Y1_Im <= 0;
	end
else
	begin
		Y1_Re <= Y1_Re_Add_Mul [DataWidth - 1:0]; 
		Y1_Im <= Y1_Im_Add_Mul [DataWidth - 1:0];
	end
end	
endmodule
