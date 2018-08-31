`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   18:17:32 06/05/2015
// Design Name:   FFT_20150605
// Module Name:   FFT_20150605_tb.v
// Project Name:  FFT_20150521
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: FFT_20150605
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module FFT_20150605_tb;
parameter DataWidth = 12;
	// Inputs
	reg clk;
	reg rst;
	reg [11:0] sample_Re_data;
	reg [11:0] sample_Im_data;
	wire signed [DataWidth+7:0] Y_Re_FIFO_Out;
	wire signed [DataWidth+7:0] Y_Im_FIFO_Out; 
	reg [1:0] FFT_output_type;
	reg [ 8:0] counter;
	reg [15:0] xr_in_test [255:0]; //Memory to Save Real Data
	reg [15:0] xi_in_test [255:0]; //Memory to Save Imag. Data
	// Outputs
	wire [12:0] dataout;

	// Instantiate the Unit Under Test (UUT)
	FFT_20150605 uut (
		.clk(clk), 
		.rst(rst), 
		.sample_Re_data(sample_Re_data), 
		.sample_Im_data(sample_Im_data), 
		.Y_Re_FIFO_Out(Y_Re_FIFO_Out),
		.Y_Im_FIFO_Out(Y_Im_FIFO_Out),
		.FFT_output_type(FFT_output_type), 
		.dataout(dataout)
	);

always 	
# 10 clk <= ~clk;
initial
begin
$readmemh("xr_in.txt", xr_in_test);//Reading xr_in Values 
$readmemh("xi_in.txt", xi_in_test);//Reading xi_in Values 
end
//for Simulation log
//integer FFT_Real, FFT_Imag;
integer FFT_Results;

always @ (posedge clk or negedge rst)
begin
if (!rst) 
	begin 
//	FFT_Real = $fopen("FFT_Real.txt","w");
//	FFT_Imag = $fopen("FFT_Imag.txt","w");
	FFT_Results = $fopen("FFT_Results.txt","w");
	$fdisplay(FFT_Results, " FFT_Real ; FFT_Imag ");	
	end
else
	begin
	$fdisplay(FFT_Results," %d; %d ; ",  Y_Re_FIFO_Out ,Y_Im_FIFO_Out);   
	end
end	
always @ (posedge clk or negedge rst)
begin
if (!rst) 
	begin 	
	sample_Re_data 	<= 0;
	sample_Im_data 	<= 0;
	counter 	<= 0;
	end 
else 				 
	begin
	if (counter == 256)
		counter  <= counter;
	else
		begin
		sample_Re_data <= xr_in_test[counter];
		sample_Im_data <= xi_in_test[counter];
		counter <= counter +1;
		end
	end
end
	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 0;
		sample_Re_data = 0;
		sample_Im_data = 0;
		FFT_output_type = 0;

		// Wait 100 ns for global reset to finish
		#100;
		rst = 1;
        
		// Add stimulus here

	end
      
endmodule

