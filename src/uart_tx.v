module uart_tx #(
    parameter CLKS_PER_BIT = 10417
)(
    input wire clk_i,
    input wire rst_i,
    input wire tx_start_i,
    input wire [7:0] tx_data_i,
    output reg TXD_o,
    output reg tx_busy_o
);

    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    reg [1:0] state = IDLE;
    reg [13:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] tx_data = 0;

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            state <= IDLE;
            TXD_o <= 1'b1; // Linia w stanie wysokim, gdy wolna
            tx_busy_o <= 0;
            clk_count <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    TXD_o <= 1'b1;
                    clk_count <= 0;
                    bit_index <= 0;
                    if (tx_start_i == 1'b1) begin
                        tx_data <= tx_data_i;
                        tx_busy_o <= 1'b1;
                        state <= START;
                    end else begin
                        tx_busy_o <= 1'b0;
                    end
                end
                
                START: begin
                    TXD_o <= 1'b0; // Bit START
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= DATA;
                    end
                end
                
                DATA: begin
                    TXD_o <= tx_data[bit_index];
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state <= STOP;
                        end
                    end
                end
                
                STOP: begin
                    TXD_o <= 1'b1; // Bit STOP
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule