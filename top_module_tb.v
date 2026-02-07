`timescale 1ns / 1ps

module top_tb();

    reg  clk   = 0;
    // clk25'i burada üretmiyoruz, TOP modülün içinden alacağız ki senkron olsun.
    reg  rst   = 0;
    wire VGA_HS;
    wire VGA_VS;
    wire [3:0] VGA_R;
    wire [3:0] VGA_G;
    wire [3:0] VGA_B;

    top TOP_SYSTEM(
        .clk(clk),
        .rst(rst),
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_R(VGA_R),
        .VGA_G(VGA_G),
        .VGA_B(VGA_B)
    );

    // 100 MHz Sistem Saati
    always #5  clk = ~clk;

    // --- GECİKME AYARI (BURASI EKLENDİ) ---
    // Sisteminin gecikmesi 3 Clock olduğu için 3 bitlik bir boru hattı kuruyoruz.
    reg [2:0] data_en_delay_pipe;
    wire write_enable;

    // Testbench'in yazma iznini 3 clock sonra ver
    assign write_enable = data_en_delay_pipe[2]; 

    // Dosya değişkenleri
    integer i   = 0;   
    integer cnt = 0;
    integer fdr, fdg, fdb;    
    
    // Simülasyon Limiti (1 Frame için yeterli süre)
    localparam SIM_LIMIT = 450000; 

    initial
    begin
        fdr = $fopen("red.txt",   "w");
        fdg = $fopen("green.txt", "w");
        fdb = $fopen("blue.txt",  "w");

        // Reset İşlemleri
        rst = 1;
        repeat (20) @(posedge clk);
        rst = 0;
        
        // Boru hattını temizle
        data_en_delay_pipe = 0;

        $display("Simulasyon Basladi... Gecikme telafisi devrede.");

        // Ana Döngü
        // TOP modülün içindeki clk25'e kilitleniyoruz (En doğrusu budur)
        repeat (SIM_LIMIT) begin
            @(posedge TOP_SYSTEM.clk25); 

            // 1. Gecikme Borusunu Kaydır (Pipeline Shift)
            // data_en sinyalini içeri al, eskileri sola it.
            data_en_delay_pipe <= {data_en_delay_pipe[1:0], TOP_SYSTEM.vga_data_en};

            // 2. Dosyaya Yazma (Gecikmiş sinyal '1' ise yaz)
            // Bu sayede VGA_R hazır olduğunda yazmış oluyoruz.
            if(write_enable)
            begin
                $fwrite(fdr, "%h", VGA_R);
                $fwrite(fdg, "%h", VGA_G);
                $fwrite(fdb, "%h", VGA_B);
                
                cnt = cnt + 1;
                if(cnt == 640)
                begin
                    $fwrite(fdr, "\n");
                    $fwrite(fdg, "\n");
                    $fwrite(fdb, "\n");    
                    cnt = 0;            
                end
            end
        end

        $fclose(fdr);
        $fclose(fdg);
        $fclose(fdb);
        
        $display("Simulasyon Bitti. Dosyalar olusturuldu.");
        $stop;
    end

endmodule