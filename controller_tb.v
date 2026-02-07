`timescale 1ns / 1ps

module tb_controller;

    // --- SİNYAL TANIMLARI ---
    reg pixel_clk;
    reg rst;
    reg data_en;
    reg [11:0] data_in;

    // Çıkışlar (Gözlemleyeceğimiz sinyaller)
    wire frame_sent;
    wire [16:0] address;

    // Kernel Çıkışları
    wire signed [3:0] k11, k12, k13, k21, k22, k23, k31, k32, k33;
    
    // Piksel Çıkışları
    wire [3:0] p11, p12, p13, p21, p22, p23, p31, p32, p33;

    // --- MODÜL BAĞLANTISI (DUT) ---
    controller uut (
        .pixel_clk(pixel_clk),
        .rst(rst),
        .data_en(data_en),
        .data_in(data_in),
        
        .frame_sent(frame_sent),
        .address(address),
        
        // Kernel Bağlantıları
        .kernel11(k11), .kernel12(k12), .kernel13(k13),
        .kernel21(k21), .kernel22(k22), .kernel23(k23),
        .kernel31(k31), .kernel32(k32), .kernel33(k33),
        
        // Piksel Bağlantıları
        .pixel11(p11), .pixel12(p12), .pixel13(p13),
        .pixel21(p21), .pixel22(p22), .pixel23(p23),
        .pixel31(p31), .pixel32(p32), .pixel33(p33)
    );

    // --- SAAT SİNYALİ OLUŞTURMA ---
    // 100 MHz clock (10ns periyot)
    initial begin
        pixel_clk = 0;
        forever #5 pixel_clk = ~pixel_clk;
    end

    // --- BLOCK RAM SİMÜLASYONU ---
    // Gerçek hayatta Block RAM adresi alır, 1 clock sonra veriyi verir.
    // Burada test amaçlı; Adres neyse, veri de o olsun (Kolay takip için).
    // Örnek: Adres 100 ise, data_in = 100 olur.
    always @(posedge pixel_clk) begin
        if (rst) begin
            data_in <= 0;
        end else begin
            // Verinin adresin alt 12 bitine eşit olduğunu varsayalım
            // Bu sayede Waveform'da "Adres 5 iken Data 5 gelmiş mi?" diye bakabiliriz.
            data_in <= address[11:0]; 
        end
    end

    // --- TEST SENARYOSU ---
    initial begin
        // 1. Başlangıç Durumu
        rst = 1;
        data_en = 0;
        $display("Simulasyon Basliyor...");
        
        // 2. Resetin Kaldırılması
        #100;
        rst = 0;
        
        // 3. Veri Akışını Başlat (VGA Active Video gibi)
        // Normalde VGA'da data_en kesikli olur (H-sync sırasında 0 olur).
        // Ancak bu modülün throughput (işleme hızı) testi için sürekli 1 tutuyoruz.
        @(posedge pixel_clk);
        data_en = 1;

        // 4. Uzun Süreli Bekleme (Frame'in bitmesini bekle)
        // Toplam 103147 adres var. Yaklaşık 105.000 clock cycle bekleyelim.
        // Bu simülasyonda birkaç milisaniye sürebilir.
        
        // Frame sent olana kadar bekle
        wait(frame_sent == 1);
        
        $display("FRAME SENT Sinyali Algilandi! Zaman: %t", $time);
        
        // 5. Kontrol: Adres Sıfırlandı mı?
        @(posedge pixel_clk); // Bir clock bekle
        if (address == 0) 
            $display("BASARILI: Frame bitti ve adres 0'a dondu.");
        else 
            $display("HATA: Frame bitti ama adres 0 degil! Adres: %d", address);

        // 6. İkinci Frame'in başladığını gör
        #500;
        $stop;
    end
    
    // --- DURUM TAKİBİ (MONITOR) ---
    // Her 10.000 adreste bir ekrana bilgi yaz, simülasyonun donmadığını görelim.
    always @(posedge pixel_clk) begin
        if (address % 10000 == 0 && address != 0) begin
            $display("Islem devam ediyor... Su anki Adres: %d", address);
        end
    end

endmodule