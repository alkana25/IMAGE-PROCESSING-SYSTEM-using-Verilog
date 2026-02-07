`timescale 1ns / 1ps

module vga_driver_tb;

    reg pixel_clk = 0;
    reg rst = 0;

    wire VGA_HS;
    wire VGA_VS;
    wire data_en;

    // DUT Instantiation
    vga_driver DUT (
        .pixel_clk(pixel_clk),
        .rst(rst),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .data_en(data_en)
    );

    // 25 MHz Clock (40ns periyot)
    always #20 pixel_clk = ~pixel_clk;

    initial begin
        rst = 1;
        repeat(5) @(posedge pixel_clk);
        rst = 0;

        // Yaklaşık 2 frame çalıştırıp zamanlamayı gözlemlemek için
        // 1 Frame = 800 * 525 = 420,000 clock
        repeat(420000 * 2) @(posedge pixel_clk);

        $stop;
    end

endmodule
