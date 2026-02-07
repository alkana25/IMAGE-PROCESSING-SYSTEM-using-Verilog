`timescale 1ns / 1ps

module blk_mem_red_tb;

    reg          clk  = 0;
    reg          ena  = 1'b1;
    reg  [16:0]  addr = 17'd0;
    wire [11:0]  dout;

    // IP Bağlantısı (Senin IP ismin neyse onu yaz)
    blk_mem_red DUT (
        .clka  (clk),
        .ena   (ena),
        .wea   (1'b0),
        .addra (addr),
        .dina  (12'd0),
        .douta (dout)
    );

    // Clock üretimi
    always #20 clk = ~clk;

    integer i;

initial begin
    repeat(10) @(posedge clk);

    $display("=== HIZALANMIS BRAM TESTI ===");

    // ---- DUMMY READ ----
    addr = 17'd250;
    @(posedge clk);   // adres örneklenir
    @(posedge clk);   // dout geçerli olur ama YOK SAYIYORUZ

    // ---- GERÇEK OKUMA ----
    for (i = 250; i <= 350; i = i + 1) begin
        addr = i;
        @(posedge clk);
        @(posedge clk);
        $display("Adres: %0d  -> Veri: %03h", addr, dout);
    end

    $display("=== TEST BITTI ===");
    $stop;
end

endmodule
