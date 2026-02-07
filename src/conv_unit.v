`timescale 1ns / 1ps

module conv_unit(
    input  wire        pixel_clk,
    input  wire        rst,
    input  wire        enable,

    // 5-bit signed pixel inputs
    input  signed [4:0] pixel11, pixel12, pixel13,
    input  signed [4:0] pixel21, pixel22, pixel23,
    input  signed [4:0] pixel31, pixel32, pixel33,

    // 4-bit signed kernel inputs
    input  signed [3:0] kernel11, kernel12, kernel13,
    input  signed [3:0] kernel21, kernel22, kernel23,
    input  signed [3:0] kernel31, kernel32, kernel33,

    // 4-bit output pixel
    output reg  [3:0]  pixel_out
);

    // Çarpma
    wire signed [8:0] p11 = pixel11 * kernel11;
    wire signed [8:0] p12 = pixel12 * kernel12;
    wire signed [8:0] p13 = pixel13 * kernel13;
    wire signed [8:0] p21 = pixel21 * kernel21;
    wire signed [8:0] p22 = pixel22 * kernel22;
    wire signed [8:0] p23 = pixel23 * kernel23;
    wire signed [8:0] p31 = pixel31 * kernel31;
    wire signed [8:0] p32 = pixel32 * kernel32;
    wire signed [8:0] p33 = pixel33 * kernel33;

    // Toplama
    wire signed [12:0] sum_all = p11 + p12 + p13 +
                                 p21 + p22 + p23 +
                                 p31 + p32 + p33;

    // PDF Madde 5: Sonucun negatifini al
    wire signed [12:0] filtered_val = -sum_all;

    // PDF Madde 6: Normalizasyon (0-15 arası sınırla)
    always @(posedge pixel_clk or posedge rst) begin
        if (rst) begin
            pixel_out <= 4'd0;
        end 
        else begin
            if (!enable) begin
                pixel_out <= 4'd0;
            end 
            else begin
                if (filtered_val > 13'sd15)
                    pixel_out <= 4'd15;
                else if (filtered_val < 13'sd0)
                    pixel_out <= 4'd0;
                else
                    pixel_out <= filtered_val[3:0];
            end
        end
    end

endmodule
