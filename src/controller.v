`timescale 1ns / 1ps

module controller(
    input pixel_clk,
    input rst,
    input data_en,                  
    input [11:0] data_in,           // BRAM'den gelen veri (Satır 3)
    
    output reg frame_sent,          
    output reg [16:0] address,      
    
    // Çekirdek (Kernel)
    output signed [3:0] kernel11, output signed [3:0] kernel12, output signed [3:0] kernel13,
    output signed [3:0] kernel21, output signed [3:0] kernel22, output signed [3:0] kernel23,
    output signed [3:0] kernel31, output signed [3:0] kernel32, output signed [3:0] kernel33,
    
    // Pikseller (3x3)
    output reg signed [4:0] pixel11, output reg signed [4:0] pixel12, output reg signed [4:0] pixel13,
    output reg signed [4:0] pixel21, output reg signed [4:0] pixel22, output reg signed [4:0] pixel23,
    output reg signed [4:0] pixel31, output reg signed [4:0] pixel32, output reg signed [4:0] pixel33
    );

    // --- PARAMETRELER ---
    localparam FIRST_LINE  = 3'd0;
    localparam SECOND_LINE = 3'd1;
    localparam PROC1       = 3'd2;
    localparam PROC2       = 3'd3;
    localparam PROC3       = 3'd4;
    localparam END_OF_LINE = 3'd5;

    // --- SİNYALLER ---
    reg [2:0] state;
    reg [11:0] buffer1 [0:213]; // Satır N-2
    reg [11:0] buffer2 [0:213]; // Satır N-1
    reg [7:0] buf_idx;          
    
    // "Şimdiki" okunan veriler (Bufferlardan ve BRAM'den)
    reg [11:0] data_buf1; 
    reg [11:0] data_buf2;
    
    // "Önceki" saklanan veriler (Kaydırma işlemi için gerekli)
    reg [11:0] prev_buf1; 
    reg [11:0] prev_buf2;
    reg [11:0] prev_data;       // BRAM'den gelenin öncesi

    // Yazma indeksi için yardımcı register (Okuma indeksi arttığı için eskisini tutar)
    reg [7:0] write_idx;

    // --- KERNEL ATAMALARI ---
    assign kernel11 = 4'sd1; assign kernel12 = 4'sd1; assign kernel13 = 4'sd1;
    assign kernel21 = 4'sd1; assign kernel22 = -4'sd8; assign kernel23 = 4'sd1;
    assign kernel31 = 4'sd1; assign kernel32 = 4'sd1; assign kernel33 = 4'sd1;

    // --- COMBINATIONAL LOGIC: PİKSEL SEÇİMİ ---
    // Mantık: PROC1'de veriler hizalıdır. PROC2 ve PROC3'te 
    // PREV (Sol taraf) ve DATA (Sağ taraf) birleştirilir.
    // data_buf ve data_in registerları o anki "YENİ" veriyi tutar (çünkü PROC1 sonunda adres arttı).
    
    always @(*) begin
        // Latch önleme
        pixel11 = 0; pixel12 = 0; pixel13 = 0;
        pixel21 = 0; pixel22 = 0; pixel23 = 0;
        pixel31 = 0; pixel32 = 0; pixel33 = 0;

        case(state)
            PROC1: begin 
                // Hizalı okuma: Doğrudan o anki PREV registerlarını kullanıyoruz.
                // Çünkü PROC1 başında 'prev' registerlarına o anki bloğu yükledik.
                // Not: Burada mantığı basitleştirmek için, PROC1 anında elimizdeki
                // hizalı blok "prev" registerlarında saklı olan bloktur diyebiliriz.
                
                // Satır 1
                pixel11 = {prev_buf1[11:8]}; pixel12 = {prev_buf1[7:4]}; pixel13 = {prev_buf1[3:0]};
                // Satır 2
                pixel21 = {prev_buf2[11:8]}; pixel22 = {prev_buf2[7:4]}; pixel23 = {prev_buf2[3:0]};
                // Satır 3
                pixel31 = {prev_data[11:8]}; pixel32 = {prev_data[7:4]}; pixel33 = {prev_data[3:0]};
            end
            
            PROC2: begin 
                // 1 Piksel Sağa Kayma: Sol taraf PREV'den, Sağ taraf YENİ DATA'dan.
                // data_buf1 şu an bir sonraki bloğu tutuyor.
                
                // Satır 1: [Prev_Mid, Prev_Right, New_Left]
                pixel11 = {prev_buf1[7:4]}; pixel12 = {prev_buf1[3:0]}; pixel13 = {data_buf1[11:8]};
                // Satır 2
                pixel21 = {prev_buf2[7:4]}; pixel22 = {prev_buf2[3:0]}; pixel23 = {data_buf2[11:8]};
                // Satır 3
                pixel31 = {prev_data[7:4]}; pixel32 = {prev_data[3:0]}; pixel33 = {data_in[11:8]};
            end
            
            PROC3: begin 
                // 2 Piksel Sağa Kayma: 
                // Satır 1: [Prev_Right, New_Left, New_Mid]
                pixel11 = {prev_buf1[3:0]}; pixel12 = {data_buf1[11:8]}; pixel13 = {data_buf1[7:4]};
                // Satır 2
                pixel21 = {prev_buf2[3:0]}; pixel22 = {data_buf2[11:8]}; pixel23 = {data_buf2[7:4]};
                // Satır 3
                pixel31 = {prev_data[3:0]}; pixel32 = {data_in[11:8]};   pixel33 = {data_in[7:4]};
            end
        endcase
    end

    // --- SEQUENTIAL LOGIC ---
    always @(posedge pixel_clk or posedge rst) begin
        if (rst) begin
            state <= FIRST_LINE;
            address <= 0;
            buf_idx <= 0;
            frame_sent <= 0;
            prev_data <= 0;
            prev_buf1 <= 0; prev_buf2 <= 0;
            data_buf1 <= 0; data_buf2 <= 0;
            write_idx <= 0;
        end else begin
            // Bufferlardan okuma her zaman aktiftir
            data_buf1 <= buffer1[buf_idx];
            data_buf2 <= buffer2[buf_idx];

            case (state)
                FIRST_LINE: begin
                    buffer1[buf_idx] <= data_in;
                    address <= address + 1;
                    if (buf_idx == 213) begin
                        buf_idx <= 0;
                        state <= SECOND_LINE;
                    end else begin
                        buf_idx <= buf_idx + 1;
                    end
                end

                SECOND_LINE: begin
                    buffer2[buf_idx] <= data_in;
                    address <= address + 1;
                    if (buf_idx == 213) begin
                        buf_idx <= 0;
                        state <= PROC1; 
                    end else begin
                        buf_idx <= buf_idx + 1;
                    end
                end

                PROC1: begin
                    if (data_en) begin
                        // 1. MEVCUT VERİYİ SAKLA (Hizalı blok)
                        // Şu anki buf_idx'teki veri bizim "Hizalı" verimizdir.
                        // Bunu prev'e atıyoruz ki PROC2 ve PROC3'te sol parça olarak kullanalım.
                        // Not: data_buf1, clock başındaki buffer1[buf_idx] değeridir.
                        prev_buf1 <= data_buf1;
                        prev_buf2 <= data_buf2;
                        prev_data <= data_in;
                        
                        // Yazma indeksi şu anki konumu tutsun (çünkü okuma ilerleyecek)
                        write_idx <= buf_idx;

                        // 2. SONRAKİ VERİYE HAZIRLAN
                        // PROC2 ve PROC3'te sağ taraftaki pikseller için "bir sonraki" bloğa ihtiyacımız var.
                        // Bu yüzden adresleri ŞİMDİ arttırıyoruz.
                        if (buf_idx == 213) begin
                             // Satır sonu geldiğinde artırmıyoruz, çünkü sonraki veri yok.
                             // END_OF_LINE durumu halledecek.
                             state <= END_OF_LINE;
                        end else begin
                             buf_idx <= buf_idx + 1;
                             address <= address + 1;
                             state <= PROC2;
                        end
                    end
                end

                PROC2: begin
                    if (data_en) begin
                        state <= PROC3;
                    end
                end

                PROC3: begin
                    if (data_en) begin
                        // Bu 3'lü paket tamamen işlendi.
                        // Bufferları güncelleme zamanı [cite: 254-255].
                        // Elimizdeki "Eski" verileri (prev registerlarında saklı olanları)
                        // bir yukarı satıra kaydırarak buffer'a geri yazıyoruz.
                        
                        // Buffer1'e <- Buffer2'nin eski verisi (prev_buf2)
                        buffer1[write_idx] <= prev_buf2;
                        
                        // Buffer2'ye <- BRAM'in eski verisi (prev_data)
                        buffer2[write_idx] <= prev_data;
                        
                        // Döngüyü başa sar, yeni okunan (data_buf ve data_in) veri
                        // bir sonraki çevrimde PROC1'in "prev"i olacak.
                        state <= PROC1;
                    end
                end

                END_OF_LINE: begin
                    // Buffer güncellemesi (Son parça için)
                    buffer1[write_idx] <= prev_buf2;
                    buffer2[write_idx] <= prev_data;
                    
                    buf_idx <= 0;
                    address <= address + 1; // Yeni satırın ilk verisi için
                    
                    if (address == 103147) begin 
                        address <= 0;
                        frame_sent <= 1;
                        state <= FIRST_LINE;
                    end else begin
                        frame_sent <= 0;
                        state <= PROC1; 
                    end
                end
            endcase
        end
    end

endmodule
