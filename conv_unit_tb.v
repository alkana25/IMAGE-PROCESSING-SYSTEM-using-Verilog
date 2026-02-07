`timescale 1ns / 1ps

module conv_unit_tb;

    reg pixel_clk;
    reg rst;
    reg enable;

    // Inputs
    reg signed [4:0] pixel11, pixel12, pixel13;
    reg signed [4:0] pixel21, pixel22, pixel23;
    reg signed [4:0] pixel31, pixel32, pixel33;
    
    reg signed [3:0] kernel11, kernel12, kernel13;
    reg signed [3:0] kernel21, kernel22, kernel23;
    reg signed [3:0] kernel31, kernel32, kernel33;

    wire [3:0] pixel_out;

    // Modül Bağlantısı
    conv_unit uut (
        .pixel_clk(pixel_clk), 
        .rst(rst), 
        .enable(enable), 
        .pixel11(pixel11), .pixel12(pixel12), .pixel13(pixel13),
        .pixel21(pixel21), .pixel22(pixel22), .pixel23(pixel23),
        .pixel31(pixel31), .pixel32(pixel32), .pixel33(pixel33),
        .kernel11(kernel11), .kernel12(kernel12), .kernel13(kernel13),
        .kernel21(kernel21), .kernel22(kernel22), .kernel23(kernel23),
        .kernel31(kernel31), .kernel32(kernel32), .kernel33(kernel33),
        .pixel_out(pixel_out)
    );

    // Clock (Modül combinational olsa bile sistemde clock bulunabilir)
    initial begin
        pixel_clk = 0;
        forever #20 pixel_clk = ~pixel_clk;
    end

    initial begin
        // --- BAŞLANGIÇ AYARLARI ---
        rst = 1;
        enable = 0;
        
        // Kernel: Laplacian (Merkez -8, Çevre 1)
        kernel11 = 1; kernel12 = 1; kernel13 = 1;
        kernel21 = 1; kernel22 = -8; kernel23 = 1;
        kernel31 = 1; kernel32 = 1; kernel33 = 1;

        // Pixeller: Sıfırla
        pixel11 = 0; pixel12 = 0; pixel13 = 0;
        pixel21 = 0; pixel22 = 0; pixel23 = 0;
        pixel31 = 0; pixel32 = 0; pixel33 = 0;

        #50;
        rst = 0;
        enable = 1;
        #50;

        // --- SENARYO 1: HEDEF 15 (Anlık Değişim) ---
        // Modül 'always @(*)' olduğu için clock beklemeye gerek yok.
        // Değer değiştiği an çıkış değişecektir.
        
        pixel22 = 15; // Merkez: 15, Çevre: 0 -> Sonuç: 120 -> Clamp: 15
        
        #100; // Sonucu görmek için bekleme süresi

        // --- SENARYO 2: HEDEF 0 (Anlık Değişim) ---
        pixel11 = 10; pixel12 = 10; pixel13 = 10;
        pixel21 = 10; pixel22 = 0;  pixel23 = 10; // Çevre: 10, Merkez: 0 -> Sonuç: -80 -> Clamp: 0
        pixel31 = 10; pixel32 = 10; pixel33 = 10;

        #100;
        
        // --- SENARYO 3: ARA DEĞER (Test Amaçlı) ---
        // Merkez 5, Çevre 0 -> Sonuç: 5*-8 = -40 -> Negatifi = 40 -> Clamp 15
        // Farklı bir kombinasyon deneyelim: Sonucun 8 çıkması için (İkinci resimdeki gibi)
        // Eğer örnek resimdeki gibi 8 istiyorsan ona uygun matematiksel giriş vermelisin.
        // Mevcut Laplacian ile 8 elde etmek zordur ama mantık çalışıyor mu bakalım.
        
        pixel11 = 0; pixel22 = 1; // 1*-8 = -8 -> Tersi +8 -> Çıkış 8
        // Çevreyi sıfırla
        pixel12=0; pixel13=0; pixel21=0; pixel23=0; pixel31=0; pixel32=0; pixel33=0;
        
        #100;

        $stop;
    end

endmodule