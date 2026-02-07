`timescale 1ns / 1ps



module top(
    input  clk,
    input  rst,
	output VGA_HS,
	output VGA_VS,
	output [3:0] VGA_R,
	output [3:0] VGA_G,
	output [3:0] VGA_B
);

	//*********************************************************** \\
	//******************* CLOCK 25 MHz ************************** \\
	//*********************************************************** \\    
	wire locked;
	
    clk_wiz_0 CLK_GEN
    (
    // Clock out ports
    .clk_out1(clk25),        // output clk_out1
    .reset(rst),             // input reset
    .locked(locked),         // output locked
    .clk_in1(clk)            // input clk_in1
    );

	//*********************************************************** \\
	//******************** VGA DRIVER ************************** \\
	//*********************************************************** \\ 	
	wire vga_data_en;

	vga_driver VGA(
		.pixel_clk(clk25),		 // 25 MHz
		.rst(rst),
		.VGA_HS(VGA_HS),
		.VGA_VS(VGA_VS),
		.data_en(vga_data_en)	
	);

	//*********************************************************** \\
	//********************** RED CHANNEL ************************ \\
	//*********************************************************** \\
	wire [16:0] red_addr;
	wire [11:0] red_data;
	
	wire [3:0] red_kernel11;
	wire [3:0] red_kernel12;
	wire [3:0] red_kernel13;
	wire [3:0] red_kernel21;
	wire [3:0] red_kernel22;
	wire [3:0] red_kernel23;
	wire [3:0] red_kernel31;
	wire [3:0] red_kernel32;
	wire [3:0] red_kernel33;

	wire [3:0] red_pixel11;
	wire [3:0] red_pixel12;
	wire [3:0] red_pixel13;
	wire [3:0] red_pixel21;
	wire [3:0] red_pixel22;
	wire [3:0] red_pixel23;
	wire [3:0] red_pixel31;
	wire [3:0] red_pixel32;
	wire [3:0] red_pixel33;
	
	wire red_frame_sent;
	
	blk_mem_red MEM_RED(
	  .clka(clk25),         // input wire clka
	  .ena(1'b1),           // input wire ena
	  .wea(1'b0),           // input wire [0 : 0] wea
	  .addra(red_addr),   // input wire [16 : 0] addra
	  .dina(),     	        // input wire [11 : 0] dina
	  .douta(red_data)    // output wire [11 : 0] douta
	);

	controller CNT_RED(
        .pixel_clk(clk25),
        .rst(rst),
        .data_en(vga_data_en),
        .data_in(red_data),
        .address(red_addr),
        .kernel11(red_kernel11),
        .kernel12(red_kernel12),
        .kernel13(red_kernel13),
        .kernel21(red_kernel21),
        .kernel22(red_kernel22),
        .kernel23(red_kernel23),
        .kernel31(red_kernel31),
        .kernel32(red_kernel32),
        .kernel33(red_kernel33),
        .pixel11(red_pixel11),
        .pixel12(red_pixel12),
        .pixel13(red_pixel13),
        .pixel21(red_pixel21),
        .pixel22(red_pixel22),
        .pixel23(red_pixel23),
        .pixel31(red_pixel31),
        .pixel32(red_pixel32),
        .pixel33(red_pixel33),
        .frame_sent(red_frame_sent)  // indicate one frame has been sent
	);
	
	conv_unit CONV_RED(
		.pixel_clk(clk25),
		.rst(rst),
		.enable(vga_data_en),
		.kernel11(red_kernel11),
		.kernel12(red_kernel12),
		.kernel13(red_kernel13),
		.kernel21(red_kernel21),
		.kernel22(red_kernel22),
		.kernel23(red_kernel23),
		.kernel31(red_kernel31),
		.kernel32(red_kernel32),
		.kernel33(red_kernel33),
		.pixel11( {1'b0, red_pixel11} ),
		.pixel12( {1'b0, red_pixel12} ),
		.pixel13( {1'b0, red_pixel13} ),
		.pixel21( {1'b0, red_pixel21} ),
		.pixel22( {1'b0, red_pixel22} ),
		.pixel23( {1'b0, red_pixel23} ),
		.pixel31( {1'b0, red_pixel31} ),
		.pixel32( {1'b0, red_pixel32} ),
		.pixel33( {1'b0, red_pixel33} ),
		.pixel_out(VGA_R)	
	);


	//*********************************************************** \\
	//******************** GREEN CHANNEL  *********************** \\
	//*********************************************************** \\
	wire [16:0] green_addr;
	wire [11:0] green_data;
	
	wire [3:0] green_kernel11;
	wire [3:0] green_kernel12;
	wire [3:0] green_kernel13;
	wire [3:0] green_kernel21;
	wire [3:0] green_kernel22;
	wire [3:0] green_kernel23;
	wire [3:0] green_kernel31;
	wire [3:0] green_kernel32;
	wire [3:0] green_kernel33;

	wire [3:0] green_pixel11;
	wire [3:0] green_pixel12;
	wire [3:0] green_pixel13;
	wire [3:0] green_pixel21;
	wire [3:0] green_pixel22;
	wire [3:0] green_pixel23;
	wire [3:0] green_pixel31;
	wire [3:0] green_pixel32;
	wire [3:0] green_pixel33;
	
	wire green_frame_sent;
	
	blk_mem_green MEM_GREEN(
	  .clka(clk25),         // input wire clka
	  .ena(1'b1),           // input wire ena
	  .wea(1'b0),           // input wire [0 : 0] wea
	  .addra(green_addr),   // input wire [16 : 0] addra
	  .dina(),     	        // input wire [11 : 0] dina
	  .douta(green_data)    // output wire [11 : 0] douta
	);

	controller CNT_GREEN(
        .pixel_clk(clk25),
        .rst(rst),
        .data_en(vga_data_en),
        .data_in(green_data),
        .address(green_addr),
        .kernel11(green_kernel11),
        .kernel12(green_kernel12),
        .kernel13(green_kernel13),
        .kernel21(green_kernel21),
        .kernel22(green_kernel22),
        .kernel23(green_kernel23),
        .kernel31(green_kernel31),
        .kernel32(green_kernel32),
        .kernel33(green_kernel33),
        .pixel11(green_pixel11),
        .pixel12(green_pixel12),
        .pixel13(green_pixel13),
        .pixel21(green_pixel21),
        .pixel22(green_pixel22),
        .pixel23(green_pixel23),
        .pixel31(green_pixel31),
        .pixel32(green_pixel32),
        .pixel33(green_pixel33),
        .frame_sent(green_frame_sent)  // indicate one frame has been sent
	);
	
	conv_unit CONV_GREEN(
		.pixel_clk(clk25),
		.rst(rst),
		.enable(vga_data_en),
		.kernel11(green_kernel11),
		.kernel12(green_kernel12),
		.kernel13(green_kernel13),
		.kernel21(green_kernel21),
		.kernel22(green_kernel22),
		.kernel23(green_kernel23),
		.kernel31(green_kernel31),
		.kernel32(green_kernel32),
		.kernel33(green_kernel33),
		.pixel11( {1'b0, green_pixel11} ),
		.pixel12( {1'b0, green_pixel12} ),
		.pixel13( {1'b0, green_pixel13} ),
		.pixel21( {1'b0, green_pixel21} ),
		.pixel22( {1'b0, green_pixel22} ),
		.pixel23( {1'b0, green_pixel23} ),
		.pixel31( {1'b0, green_pixel31} ),
		.pixel32( {1'b0, green_pixel32} ),
		.pixel33( {1'b0, green_pixel33} ),
		.pixel_out(VGA_G)	
	);
	
	//*********************************************************** \\
	//******************** BLUE CHANNEL  ************************ \\
	//*********************************************************** \\
	wire [16:0] blue_addr;
	wire [11:0] blue_data;
	
	wire [3:0] blue_kernel11;
	wire [3:0] blue_kernel12;
	wire [3:0] blue_kernel13;
	wire [3:0] blue_kernel21;
	wire [3:0] blue_kernel22;
	wire [3:0] blue_kernel23;
	wire [3:0] blue_kernel31;
	wire [3:0] blue_kernel32;
	wire [3:0] blue_kernel33;

	wire [3:0] blue_pixel11;
	wire [3:0] blue_pixel12;
	wire [3:0] blue_pixel13;
	wire [3:0] blue_pixel21;
	wire [3:0] blue_pixel22;
	wire [3:0] blue_pixel23;
	wire [3:0] blue_pixel31;
	wire [3:0] blue_pixel32;
	wire [3:0] blue_pixel33;
	
	wire blue_frame_sent;
	
	blk_mem_blue MEM_BLUE (
	  .clka(clk25),        // input wire clka
	  .ena(1'b1),          // input wire ena
	  .wea(1'b0),          // input wire [0 : 0] wea
	  .addra(blue_addr),   // input wire [16 : 0] addra
	  .dina(),     	       // input wire [11 : 0] dina
	  .douta(blue_data)    // output wire [11 : 0] douta
	);

	controller CNT_BLUE(
        .pixel_clk(clk25),
        .rst(rst),
        .data_en(vga_data_en),
        .data_in(blue_data),
        .address(blue_addr),
        .kernel11(blue_kernel11),
        .kernel12(blue_kernel12),
        .kernel13(blue_kernel13),
        .kernel21(blue_kernel21),
        .kernel22(blue_kernel22),
        .kernel23(blue_kernel23),
        .kernel31(blue_kernel31),
        .kernel32(blue_kernel32),
        .kernel33(blue_kernel33),
        .pixel11(blue_pixel11),
        .pixel12(blue_pixel12),
        .pixel13(blue_pixel13),
        .pixel21(blue_pixel21),
        .pixel22(blue_pixel22),
        .pixel23(blue_pixel23),
        .pixel31(blue_pixel31),
        .pixel32(blue_pixel32),
        .pixel33(blue_pixel33),
        .frame_sent(blue_frame_sent)  // indicate one frame has been sent
	);
	
	conv_unit CONV_BLUE(
		.pixel_clk(clk25),
		.rst(rst),
		.enable(vga_data_en),
		.kernel11(blue_kernel11),
		.kernel12(blue_kernel12),
		.kernel13(blue_kernel13),
		.kernel21(blue_kernel21),
		.kernel22(blue_kernel22),
		.kernel23(blue_kernel23),
		.kernel31(blue_kernel31),
		.kernel32(blue_kernel32),
		.kernel33(blue_kernel33),
		.pixel11( {1'b0, blue_pixel11} ),
		.pixel12( {1'b0, blue_pixel12} ),
		.pixel13( {1'b0, blue_pixel13} ),
		.pixel21( {1'b0, blue_pixel21} ),
		.pixel22( {1'b0, blue_pixel22} ),
		.pixel23( {1'b0, blue_pixel23} ),
		.pixel31( {1'b0, blue_pixel31} ),
		.pixel32( {1'b0, blue_pixel32} ),
		.pixel33( {1'b0, blue_pixel33} ),
		.pixel_out(VGA_B)	
	);

endmodule
