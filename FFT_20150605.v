`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:15:05 06/05/2015 
// Design Name: 
// Module Name:    FFT_20150605 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module FFT_20150605//=============================================================================	
//========================= ParametersDeclarations ===========================		
//=============================================================================
#(
 // The width of the input, output and twiddle factors.
parameter Num_Points = 256, // Number of points
parameter Num_Stages = 8, //Num_Stages =log2(N); % Number of stages
parameter Stage_1_Points = 256,
parameter Stage_2_Points = 128,
parameter Stage_3_Points = 64,
parameter Stage_4_Points = 32,
parameter Stage_5_Points = 16,
parameter Stage_6_Points = 8,
parameter Stage_7_Points = 4,
parameter Stage_8_Points = 2,
parameter DataWidth = 12
 )
//=============================================================================
//======================== InputsDeclarations ============================
//============================================================================= 
(
		input  wire clk, 
		input  wire rst,
		input  wire signed [DataWidth-1:0] sample_Re_data,
		input  wire signed [DataWidth-1:0] sample_Im_data,
		output reg  signed [DataWidth+7:0] Y_Re_FIFO_Out,
		output reg  signed [DataWidth+7:0] Y_Im_FIFO_Out,
		input  wire [1:0]FFT_output_type,
		output wire [DataWidth:0] dataout
    );
//=============================================================================
//=========================== Wire Declarations ===============================
//=============================================================================
wire [8:0] N; // Number of points
reg  Stage_1_Start;
wire Stage_2_Start, Stage_3_Start, Stage_4_Start, 
	  Stage_5_Start, Stage_6_Start, Stage_7_Start, Stage_8_Start;
wire Stage_8_Done;
//assign N = 4;
//=============================================================================
//========================= Registers Declarations ============================
//=============================================================================	
reg signed [DataWidth-1:0] X_r_data,  X_i_data; // Real and imag. input 
//fifo for saveing data.
reg  signed [DataWidth-1:0] X_Re_FIFO [0:255];	
reg  signed [DataWidth-1:0] X_Im_FIFO [0:255];
wire signed [DataWidth	:0] Y_Re_FIFO [0:255];	
wire signed [DataWidth	:0] Y_Im_FIFO [0:255];
reg 			[31:0] 			 cos_rom [127:0];
reg 			[31:0] 			 sin_rom [127:0];
reg 			[8:0]  			 counter;
reg  Read_Done;


//=============================================================================
//========================== Initializations ==================================
//============================================================================= 
initial
begin
$readmemh("cos128x16.txt", cos_rom);//Reading Cosine Values to calculate Twiddle Factor
$readmemh("sin128x16.txt", sin_rom);//Reading Sine Values to calculate Twiddle Factor
end 
//=============================================================================
//======================== Sequential  Logic  =================================
//=============================================================================
//read all 256 points as Input Data one by one
always@(posedge clk) 
begin
if (!rst)
	begin
	counter <= 0; //Read_Done <=0;
	end
 else
	begin
	if (counter < 256)
		begin
		X_Re_FIFO[counter] <=  sample_Re_data; //Real Data Input
		X_Im_FIFO[counter] <=  sample_Im_data; //Imag Data Input
		counter <= counter +1'b1; Read_Done <=0;
		Stage_1_Start <=0;
		end
	if (counter == 255)
		Stage_1_Start <=1;
	else
		Read_Done <=1;
	end
end
//=============================================================================
//======================== Combinational Logic ================================
//============================================================================= 
//===================================================================
// For interconnection between Stages
wire signed [DataWidth	:0] Y_Re_FIFO_S1 [0:255];	wire signed [DataWidth	:0] Y_Im_FIFO_S1 [0:255];
wire signed [DataWidth+1:0] Y_Re_FIFO_S2 [0:255];	wire signed [DataWidth+1:0] Y_Im_FIFO_S2 [0:255];
wire signed [DataWidth+2:0] Y_Re_FIFO_S3 [0:255];	wire signed [DataWidth+2:0] Y_Im_FIFO_S3 [0:255];
wire signed [DataWidth+3:0] Y_Re_FIFO_S4 [0:255];	wire signed [DataWidth+3:0] Y_Im_FIFO_S4 [0:255];
wire signed [DataWidth+4:0] Y_Re_FIFO_S5 [0:255];	wire signed [DataWidth+4:0] Y_Im_FIFO_S5 [0:255];
wire signed [DataWidth+5:0] Y_Re_FIFO_S6 [0:255];	wire signed [DataWidth+5:0] Y_Im_FIFO_S6 [0:255];
wire signed [DataWidth+6:0] Y_Re_FIFO_S7 [0:255];	wire signed [DataWidth+6:0] Y_Im_FIFO_S7 [0:255];
wire signed [DataWidth+7:0] Y_Re_FIFO_S8 [0:255];	wire signed [DataWidth+7:0] Y_Im_FIFO_S8 [0:255];
//===================================================================
//======================    Stage 1     =============================
//===================================================================
genvar Stage_1_Index;	 
generate

			for ( Stage_1_Index =0; Stage_1_Index < (Stage_1_Points/2); Stage_1_Index = Stage_1_Index+1)
			begin : Stage_1_points
			initial $display("Stage_1_Index=%0d:",Stage_1_Index);
			//initial $display("Stages=%0d: k=%0d, n=%0d",Stages, k, n);
		 //Instantiate the Butterfly_Radix2 Unit 
			Butterfly_Radix2 # (DataWidth) Butterfly_Stage(
			.clk(clk), 
			.rst(rst),
			//.Start(Stage_1_Start),
			//.Done(Stage_2_Start),
			.X0_Re(X_Re_FIFO[Stage_1_Index]), 							// index_0 
			.X0_Im(X_Im_FIFO[Stage_1_Index]), 							// index_0 
			.X1_Re(X_Re_FIFO[Stage_1_Index+((Stage_1_Points)/2)]), 	// index_1 
			.X1_Im(X_Im_FIFO[Stage_1_Index+((Stage_1_Points)/2)]), 	// index_1 
			.sin(sin_rom[Stage_1_Index]), 
			.cos(cos_rom[Stage_1_Index]),
			.Y0_Re(Y_Re_FIFO_S1[Stage_1_Index]), 						//Output need bit reverse operation
			.Y0_Im(Y_Im_FIFO_S1[Stage_1_Index]), 						//Output need bit reverse operation
			.Y1_Re(Y_Re_FIFO_S1[Stage_1_Index+((Stage_1_Points)/2)]), //Output need bit reverse operation
			.Y1_Im(Y_Im_FIFO_S1[Stage_1_Index+((Stage_1_Points)/2)]) 	//Output need bit reverse operation
			);
			end
//			end
endgenerate	 
//===================================================================
//======================    Stage 2     =============================
//===================================================================
genvar Stage_2_Level, Stage_2_Index;	 
generate
		for (Stage_2_Level =0; Stage_2_Level < (Num_Points-Stage_2_Points+1); Stage_2_Level = (Stage_2_Level + (Stage_2_Points)))
		begin : Stage_2_Levels
		initial $display("Stage_2_Level=%0d:",Stage_2_Level);
			for ( Stage_2_Index =0; Stage_2_Index < (Stage_2_Points/2); Stage_2_Index = Stage_2_Index+1)
			begin : Stage_2_points
			initial $display("Stage_2_Index=%0d:",Stage_2_Index);
			//initial $display("Stages=%0d: Stage_2_Level=%0d, n=%0d",Stages, Stage_2_Level, Stage_2_Index);
		 //Instantiate the Butterfly_Radix2 Unit 
			Butterfly_Radix2 # (DataWidth+1) Butterfly_Stage(
			.clk(clk), 
			.rst(rst), 		
			//.Start(Stage_2_Start),
//			.Done(Stage_3_Start),			
			.X0_Re(Y_Re_FIFO_S1[Stage_2_Index+Stage_2_Level]), 							// index_0 
			.X0_Im(Y_Im_FIFO_S1[Stage_2_Index+Stage_2_Level]), 							// index_0 
			.X1_Re(Y_Re_FIFO_S1[Stage_2_Index+Stage_2_Level+((Stage_2_Points)/2)]), 	// index_1 
			.X1_Im(Y_Im_FIFO_S1[Stage_2_Index+Stage_2_Level+((Stage_2_Points)/2)]), 	// index_1 
			.sin(sin_rom[Stage_2_Index*2]), 
			.cos(cos_rom[Stage_2_Index*2]),
			.Y0_Re(Y_Re_FIFO_S2[Stage_2_Index+Stage_2_Level]), 						//Output need bit reverse operation
			.Y0_Im(Y_Im_FIFO_S2[Stage_2_Index+Stage_2_Level]), 						//Output need bit reverse operation
			.Y1_Re(Y_Re_FIFO_S2[Stage_2_Index+Stage_2_Level+((Stage_2_Points)/2)]), //Output need bit reverse operation
			.Y1_Im(Y_Im_FIFO_S2[Stage_2_Index+Stage_2_Level+((Stage_2_Points)/2)]) 	//Output need bit reverse operation
			);
			end
		end
endgenerate	 
//===================================================================
//======================    Stage 3     =============================
//===================================================================
genvar Stage_3_Level, Stage_3_Index;	 
generate
		for (Stage_3_Level =0; Stage_3_Level < (Num_Points-Stage_3_Points+1); Stage_3_Level = (Stage_3_Level + (Stage_3_Points)))
		begin : Stage_3_Levels
		initial $display("Stage_3_Level=%0d:",Stage_3_Level);
			for ( Stage_3_Index =0; Stage_3_Index < (Stage_3_Points/2); Stage_3_Index = Stage_3_Index+1)
			begin : Stage_3_points
			initial $display("Stage_3_Index=%0d:",Stage_3_Index);
			//initial $display("Stages=%0d: Stage_3_Level=%0d, n=%0d",Stages, Stage_3_Level, Stage_3_Index);
		 //Instantiate the Butterfly_Radix2 Unit 
			Butterfly_Radix2 # (DataWidth+2) Butterfly_Stage(
			.clk(clk), 
			.rst(rst),
//			.Start(Stage_3_Start),
//			.Done(Stage_4_Start),
			.X0_Re(Y_Re_FIFO_S2[Stage_3_Index+Stage_3_Level]), 							// index_0 
			.X0_Im(Y_Im_FIFO_S2[Stage_3_Index+Stage_3_Level]), 							// index_0 
			.X1_Re(Y_Re_FIFO_S2[Stage_3_Index+Stage_3_Level+((Stage_3_Points)/2)]), 	// index_1 
			.X1_Im(Y_Im_FIFO_S2[Stage_3_Index+Stage_3_Level+((Stage_3_Points)/2)]), 	// index_1 
			.sin(sin_rom[Stage_3_Index*4]), 
			.cos(cos_rom[Stage_3_Index*4]),			
			.Y0_Re(Y_Re_FIFO_S3[Stage_3_Index+Stage_3_Level]), 						//Output need bit reverse operation
			.Y0_Im(Y_Im_FIFO_S3[Stage_3_Index+Stage_3_Level]), 						//Output need bit reverse operation
			.Y1_Re(Y_Re_FIFO_S3[Stage_3_Index+Stage_3_Level+((Stage_3_Points)/2)]), //Output need bit reverse operation
			.Y1_Im(Y_Im_FIFO_S3[Stage_3_Index+Stage_3_Level+((Stage_3_Points)/2)]) 	//Output need bit reverse operation
			);
			end
		end
endgenerate	 

//===================================================================
//======================    Stage 4     =============================
//===================================================================
genvar Stage_4_Level, Stage_4_Index;	 
generate
		for (Stage_4_Level =0; Stage_4_Level < (Num_Points-Stage_4_Points+1); Stage_4_Level = (Stage_4_Level + (Stage_4_Points)))
		begin : Stage_4_Levels
		initial $display("Stage_4_Level=%0d:",Stage_4_Level);
			for ( Stage_4_Index =0; Stage_4_Index < (Stage_4_Points/2); Stage_4_Index = Stage_4_Index+1)
			begin : Stage_4_points
			initial $display("Stage_4_Index=%0d:",Stage_4_Index);
			//initial $display("Stages=%0d: Stage_4_Level=%0d, n=%0d",Stages, Stage_4_Level, Stage_4_Index);
		 //Instantiate the Butterfly_Radix2 Unit 
			Butterfly_Radix2 # (DataWidth+3) Butterfly_Stage(
			.clk(clk), 
			.rst(rst), 
//			.Start(Stage_4_Start),	
//			.Done(Stage_5_Start),
			.X0_Re(Y_Re_FIFO_S3[Stage_4_Index+Stage_4_Level]), 							// index_0 
			.X0_Im(Y_Im_FIFO_S3[Stage_4_Index+Stage_4_Level]), 							// index_0 
			.X1_Re(Y_Re_FIFO_S3[Stage_4_Index+Stage_4_Level+((Stage_4_Points)/2)]), 	// index_1 
			.X1_Im(Y_Im_FIFO_S3[Stage_4_Index+Stage_4_Level+((Stage_4_Points)/2)]), 	// index_1
			.sin(sin_rom[Stage_4_Index*8]), 
			.cos(cos_rom[Stage_4_Index*8]),				
			.Y0_Re(Y_Re_FIFO_S4[Stage_4_Index+Stage_4_Level]), 						//Output need bit reverse operation
			.Y0_Im(Y_Im_FIFO_S4[Stage_4_Index+Stage_4_Level]), 						//Output need bit reverse operation
			.Y1_Re(Y_Re_FIFO_S4[Stage_4_Index+Stage_4_Level+((Stage_4_Points)/2)]), //Output need bit reverse operation
			.Y1_Im(Y_Im_FIFO_S4[Stage_4_Index+Stage_4_Level+((Stage_4_Points)/2)])	//Output need bit reverse operation
			);
			end
		end
endgenerate	 

//===================================================================
//======================    Stage 5     =============================
//===================================================================
genvar Stage_5_Level, Stage_5_Index;	 
generate
		for (Stage_5_Level =0; Stage_5_Level < (Num_Points-Stage_5_Points+1); Stage_5_Level = (Stage_5_Level + (Stage_5_Points)))
		begin : Stage_5_Levels
		initial $display("Stage_5_Level=%0d:",Stage_5_Level);
			for ( Stage_5_Index =0; Stage_5_Index < (Stage_5_Points/2); Stage_5_Index = Stage_5_Index+1)
			begin : Stage_5_points
			initial $display("Stage_5_Index=%0d:",Stage_5_Index);
			//initial $display("Stages=%0d: Stage_5_Level=%0d, n=%0d",Stages, Stage_5_Level, Stage_5_Index);
		 //Instantiate the Butterfly_Radix2 Unit 
			Butterfly_Radix2 # (DataWidth+4) Butterfly_Stage(
			.clk(clk), 
			.rst(rst), 
//			.Start(Stage_5_Start),	
//			.Done(Stage_6_Start),
			.X0_Re(Y_Re_FIFO_S4[Stage_5_Index+Stage_5_Level]), 							// index_0 
			.X0_Im(Y_Im_FIFO_S4[Stage_5_Index+Stage_5_Level]), 							// index_0 
			.X1_Re(Y_Re_FIFO_S4[Stage_5_Index+Stage_5_Level+((Stage_5_Points)/2)]), 	// index_1 
			.X1_Im(Y_Im_FIFO_S4[Stage_5_Index+Stage_5_Level+((Stage_5_Points)/2)]), 	// index_1 
			.sin(sin_rom[Stage_5_Index*16]), 
			.cos(cos_rom[Stage_5_Index*16]),			
			.Y0_Re(Y_Re_FIFO_S5[Stage_5_Index+Stage_5_Level]), 						//Output need bit reverse operation
			.Y0_Im(Y_Im_FIFO_S5[Stage_5_Index+Stage_5_Level]), 						//Output need bit reverse operation
			.Y1_Re(Y_Re_FIFO_S5[Stage_5_Index+Stage_5_Level+((Stage_5_Points)/2)]), //Output need bit reverse operation
			.Y1_Im(Y_Im_FIFO_S5[Stage_5_Index+Stage_5_Level+((Stage_5_Points)/2)]) 	//Output need bit reverse operation
			);
			end
		end
endgenerate	 
//===================================================================
//======================    Stage 6     =============================
//===================================================================
genvar Stage_6_Level, Stage_6_Index;	 
generate
		for (Stage_6_Level =0; Stage_6_Level < (Num_Points-Stage_6_Points+1); Stage_6_Level = (Stage_6_Level + (Stage_6_Points)))
		begin : Stage_6_Levels
		initial $display("Stage_6_Level=%0d:",Stage_6_Level);
			for ( Stage_6_Index =0; Stage_6_Index < (Stage_6_Points/2); Stage_6_Index = Stage_6_Index+1)
			begin : Stage_6_points
			initial $display("Stage_6_Index=%0d:",Stage_6_Index);
			//initial $display("Stages=%0d: Stage_6_Level=%0d, n=%0d",Stages, Stage_6_Level, Stage_6_Index);
		 //Instantiate the Butterfly_Radix2 Unit 
			Butterfly_Radix2 # (DataWidth+5) Butterfly_Stage(
			.clk(clk), 
			.rst(rst), 
//			.Start(Stage_6_Start),	
//			.Done(Stage_7_Start),
			.X0_Re(Y_Re_FIFO_S5[Stage_6_Index+Stage_6_Level]), 							// index_0 
			.X0_Im(Y_Im_FIFO_S5[Stage_6_Index+Stage_6_Level]), 							// index_0 
			.X1_Re(Y_Re_FIFO_S5[Stage_6_Index+Stage_6_Level+((Stage_6_Points)/2)]), 	// index_1 
			.X1_Im(Y_Im_FIFO_S5[Stage_6_Index+Stage_6_Level+((Stage_6_Points)/2)]), 	// index_1 
			.sin(sin_rom[Stage_6_Index*32]), 
			.cos(cos_rom[Stage_6_Index*32]),
			.Y0_Re(Y_Re_FIFO_S6[Stage_6_Index+Stage_6_Level]), 						//Output need bit reverse operation
			.Y0_Im(Y_Im_FIFO_S6[Stage_6_Index+Stage_6_Level]), 						//Output need bit reverse operation
			.Y1_Re(Y_Re_FIFO_S6[Stage_6_Index+Stage_6_Level+((Stage_6_Points)/2)]), //Output need bit reverse operation
			.Y1_Im(Y_Im_FIFO_S6[Stage_6_Index+Stage_6_Level+((Stage_6_Points)/2)]) 	//Output need bit reverse operation
			
			);
			end
		end
endgenerate	 
//===================================================================
//======================    Stage 7     =============================
//===================================================================
genvar Stage_7_Level, Stage_7_Index;	 
generate
		for (Stage_7_Level =0; Stage_7_Level < (Num_Points-Stage_7_Points+1); Stage_7_Level = (Stage_7_Level + (Stage_7_Points)))
		begin : Stage_7_Levels
		initial $display("Stage_7_Level=%0d:",Stage_7_Level);
			for ( Stage_7_Index =0; Stage_7_Index < (Stage_7_Points/2); Stage_7_Index = Stage_7_Index+1)
			begin : Stage_7_points
			initial $display("Stage_7_Index=%0d:",Stage_7_Index);
			//initial $display("Stages=%0d: Stage_7_Level=%0d, n=%0d",Stages, Stage_7_Level, Stage_7_Index);
		 //Instantiate the Butterfly_Radix2 Unit 
			Butterfly_Radix2 # (DataWidth+6) Butterfly_Stage(
			.clk(clk), 
			.rst(rst), 			
//			.Start(Stage_7_Start),	
//			.Done(Stage_8_Start),
			.X0_Re(Y_Re_FIFO_S6[Stage_7_Index+Stage_7_Level]), 							// index_0 
			.X0_Im(Y_Im_FIFO_S6[Stage_7_Index+Stage_7_Level]), 							// index_0 
			.X1_Re(Y_Re_FIFO_S6[Stage_7_Index+Stage_7_Level+((Stage_7_Points)/2)]), 	// index_1 
			.X1_Im(Y_Im_FIFO_S6[Stage_7_Index+Stage_7_Level+((Stage_7_Points)/2)]), 	// index_1 
			.sin(sin_rom[Stage_7_Index*64]), 
			.cos(cos_rom[Stage_7_Index*64]),			
			.Y0_Re(Y_Re_FIFO_S7[Stage_7_Index+Stage_7_Level]), 						//Output need bit reverse operation
			.Y0_Im(Y_Im_FIFO_S7[Stage_7_Index+Stage_7_Level]), 						//Output need bit reverse operation
			.Y1_Re(Y_Re_FIFO_S7[Stage_7_Index+Stage_7_Level+((Stage_7_Points)/2)]), //Output need bit reverse operation
			.Y1_Im(Y_Im_FIFO_S7[Stage_7_Index+Stage_7_Level+((Stage_7_Points)/2)]) 	//Output need bit reverse operation
			);
			end
		end
endgenerate	 
//===================================================================
//======================    Stage 8     =============================
//===================================================================
genvar Stage_8_Level, Stage_8_Index;	 
generate
		for (Stage_8_Level =0; Stage_8_Level < (Num_Points-Stage_8_Points+1); Stage_8_Level = (Stage_8_Level + (Stage_8_Points)))
		begin : Stage_8_Levels
		initial $display("Stage_8_Level=%0d:",Stage_8_Level);
			for ( Stage_8_Index =0; Stage_8_Index < (Stage_8_Points/2); Stage_8_Index = Stage_8_Index+1)
			begin : Stage_8_points
			initial $display("Stage_8_Index=%0d:",Stage_8_Index);
			//initial $display("Stages=%0d: Stage_8_Level=%0d, n=%0d",Stages, Stage_8_Level, Stage_8_Index);
		 //Instantiate the Butterfly_Radix2 Unit 
			Butterfly_Radix2 # (DataWidth+7) Butterfly_Stage(
			.clk(clk), 
			.rst(rst),
//			.Start(Stage_8_Start),	
//			.Done(Stage_8_Done),
			.X0_Re(Y_Re_FIFO_S7[Stage_8_Index+Stage_8_Level]), 							// index_0 
			.X0_Im(Y_Im_FIFO_S7[Stage_8_Index+Stage_8_Level]), 							// index_0 
			.X1_Re(Y_Re_FIFO_S7[Stage_8_Index+Stage_8_Level+((Stage_8_Points)/2)]), 	// index_1 
			.X1_Im(Y_Im_FIFO_S7[Stage_8_Index+Stage_8_Level+((Stage_8_Points)/2)]), 	// index_1 
			.sin(sin_rom[Stage_8_Index*128]), 
			.cos(cos_rom[Stage_8_Index*128]),
			.Y0_Re(Y_Re_FIFO_S8[Stage_8_Index+Stage_8_Level]), 						//Output need bit reverse operation
			.Y0_Im(Y_Im_FIFO_S8[Stage_8_Index+Stage_8_Level]), 						//Output need bit reverse operation
			.Y1_Re(Y_Re_FIFO_S8[Stage_8_Index+Stage_8_Level+((Stage_8_Points)/2)]), //Output need bit reverse operation
			.Y1_Im(Y_Im_FIFO_S8[Stage_8_Index+Stage_8_Level+((Stage_8_Points)/2)]) 	//Output need bit reverse operation
			);
			end
		end
endgenerate	 

//assign Done_All = Stage_8_Done;

//===================================================================
//Num_Points
wire signed [DataWidth+7:0] Y_Re_FIFO_Final [0:255];	wire signed [DataWidth+7:0] Y_Im_FIFO_Final [0:255];
genvar Index;	
generate

for (Index =0; Index < 256; Index = Index + 1)
	begin : Bit_Reverse
//	if (Stage_8_Done(Index))
//		begin
//	   assign Reverse_Index = {Index[0],Index[1],Index[2],Index[3],Index[4],Index[5],Index[6],Index[7]};
//		initial $display("Index=%0b:, Reverse_Index=%0b:", Index ,{Index[0],Index[1],Index[2],Index[3],Index[4],Index[5],Index[6],Index[7]});
//		initial $display("Index=%0d:, Reverse_Index=%0d:", Index ,{Index[0],Index[1],Index[2],Index[3],Index[4],Index[5],Index[6],Index[7]});
		assign	Y_Re_FIFO_Final [{Index[0],Index[1],Index[2],Index[3],Index[4],Index[5],Index[6],Index[7]}] = Y_Re_FIFO_S8[Index];  //Output after bit reverse operation
		assign	Y_Im_FIFO_Final [{Index[0],Index[1],Index[2],Index[3],Index[4],Index[5],Index[6],Index[7]}] = Y_Re_FIFO_S8[Index];	//Output after bit reverse operation
		initial $display("Y_Re_FIFO_Final=%0d:", Y_Re_FIFO_Final [Index] );
//		initial $display("Index=%0d:, Reverse_Index=%0d:", Index ,{Index[0],Index[1],Index[2],Index[3],Index[4],Index[5],Index[6],Index[7]});
//		end
	end
endgenerate	
 
reg [8:0] count; 
always @ (posedge clk )//or negedge rst
begin
if (rst) 
	begin 
	Y_Re_FIFO_Out <= 0; 
	Y_Im_FIFO_Out <= 0;
	count <= 1'b0; 
	end
else
	begin
	Y_Re_FIFO_Out <= Y_Re_FIFO_Final [count];
	Y_Im_FIFO_Out <= Y_Im_FIFO_Final [count];
	count <= count + 1'b1; 
	end
end

endmodule



