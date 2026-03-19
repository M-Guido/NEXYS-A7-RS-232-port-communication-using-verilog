module top (
    input wire clk_i,
    input wire rst_i,
    input wire RXD_i,
    output wire TXD_o,
    output wire [7:0] rx_dbg_o,
    output wire [7:0] tx_dbg_o
);  
    wire [7:0] rx_data;
    wire rx_done;
    wire tx_busy;
    
    reg [7:0] tx_data_reg;
    reg tx_start_reg;

    // Podpięcie danych do diod LED (podgląd kodów ASCII w czasie rzeczywistym)
    assign rx_dbg_o = rx_data;
    assign tx_dbg_o = tx_data_reg;

    // Instancja odbiornika
    uart_rx rx_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .RXD_i(RXD_i),
        .rx_data_o(rx_data),
        .rx_done_o(rx_done)
    );

    // Instancja nadajnika
    uart_tx tx_inst (
        .clk_i(clk_i),
        .rst_i(rst_i),
        .tx_start_i(tx_start_reg),
        .tx_data_i(tx_data_reg),
        .TXD_o(TXD_o),
        .tx_busy_o(tx_busy)
    );

    // Logika sumatora - dodanie 20h
    always @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
        tx_data_reg <= 8'd0;
        tx_start_reg <= 1'b0;
    end else begin
        if (rx_done && !tx_busy) begin
            if (rx_data >= 8'h41 && rx_data <= 8'h5A)
                tx_data_reg <= rx_data + 8'h20;
            else
                tx_data_reg <= rx_data;
            tx_start_reg <= 1'b1;
        end else begin
            tx_start_reg <= 1'b0;
        end
    end
end 
endmodule
