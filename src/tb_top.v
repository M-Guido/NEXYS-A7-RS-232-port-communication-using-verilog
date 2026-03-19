`timescale 1ns / 1ps

module tb_top;

    // Sygnały wejściowe do naszego układu (w testbenchu są to rejestry, bo nimi sterujemy)
    reg clk_i;
    reg rst_i;
    reg RXD_i;

    // Sygnały wyjściowe z naszego układu (w testbenchu są to przewody, bo tylko je obserwujemy)
    wire TXD_o;
    wire [7:0] rx_dbg_o;
    wire [7:0] tx_dbg_o;

    // Parametry czasowe
    // Zegar 100 MHz oznacza, że jeden pełny cykl trwa 10 ns
    localparam CLK_PERIOD = 10; 
    
    // Czas trwania jednego bitu dla 9600 bps:
    // 10417 cykli zegara * 10 ns = 104170 ns
    localparam BIT_PERIOD = 104170; 

    // Instancja naszego głównego modułu (UUT - Unit Under Test)
    top uut (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .RXD_i(RXD_i),
        .TXD_o(TXD_o),
        .rx_dbg_o(rx_dbg_o),
        .tx_dbg_o(tx_dbg_o)
    );

    // Generator zegara 100 MHz (zmienia stan co 5 ns)
    always #(CLK_PERIOD/2) clk_i = ~clk_i;

    // Zadanie (task) symulujące wysyłanie 1 bajtu z komputera PC do układu
    task send_byte;
        input [7:0] data_to_send;
        integer i;
        begin
            // 1. Wyślij bit START (linia w dół na czas jednego bitu)
            RXD_i = 1'b0;
            #(BIT_PERIOD);
            
            // 2. Wyślij 8 bitów danych (od LSB do MSB)
            for (i = 0; i < 8; i = i + 1) begin
                RXD_i = data_to_send[i];
                #(BIT_PERIOD);
            end
            
            // 3. Wyślij bit STOP (linia w górę na czas jednego bitu)
            RXD_i = 1'b1;
            #(BIT_PERIOD);
        end
    endtask

    // Główny blok stymulacyjny
    initial begin
        // Inicjalizacja sygnałów
        clk_i = 0;
        rst_i = 1;       // Aktywny reset (ustawienie początkowe)
        RXD_i = 1'b1;    // Linia RX w stanie bezczynności (wysoka)

        // Odczekaj chwilę, aby układ się zresetował, i wyłącz reset
        #100;
        rst_i = 0;
        
        // Odczekaj dodatkowy czas przed rozpoczęciem transmisji
        #1000;

        // Symulujemy komputer wysyłający znak 'A' (kod ASCII: 41h / 65 w dziesiętnym)
        $display("Rozpoczynam wysyłanie znaku 'A' (0x41) do FPGA...");
        send_byte(8'h41);
        
        $display("Wyslano znak. Oczekuje na odpowiedz z FPGA...");

        // Układ teraz odbierze znak, doda 20h i zacznie go nadawać.
        // Nadanie 1 znaku (Start + 8 danych + Stop) trwa 10 bitów. 
        // Dajemy mu trochę marginesu czasowego (12 bitów), żeby spokojnie skończył.
        #(BIT_PERIOD * 12);
        
        $display("Koniec symulacji! Sprawdz wykresy czasowe, czy tx_dbg_o wynosi 0x61 ('a').");
        
        // Zakończenie symulacji
        $finish;
    end

endmodule