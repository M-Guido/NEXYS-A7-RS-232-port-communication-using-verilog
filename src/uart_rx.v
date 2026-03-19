module uart_rx #(
    parameter CLKS_PER_BIT = 10417 // 100MHz / 9600
)(
    input wire clk_i,
    input wire rst_i,
    input wire RXD_i,
    output reg [7:0] rx_data_o,
    output reg rx_done_o
);

    localparam IDLE =   2'b00;
    localparam START =   2'b01;
    localparam DATA =   2'b10;
    localparam STOP =   2'b11;

    reg[1:0] state = IDLE;
    reg [13:0] clk_count = 0;
    reg [2:0] bit_index = 0;
    reg [7:0] rx_data = 0;

    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i) begin
            state<= IDLE;
            rx_data_o <= 0;
            clk_count <=0;
            bit_index <=0;
            rx_done_o <=0;
        end else begin
            rx_done_o <=0;

            case (state)
                IDLE: begin
                    clk_count <=0;
                    bit_index <=0;
                    if(RXD_i == 1'b0) state <= START; 
                    end
                START: begin
                    if (clk_count == CLKS_PER_BIT / 2)begin
                        if (RXD_i == 1'b0) begin
                            clk_count <=0;
                            state <= DATA;
                        end 
                        else begin
                            state <= IDLE;
                        end
                    end 
                    else begin
                        clk_count <= clk_count +1;
                    end
                end
                DATA: begin
                    if (clk_count < CLKS_PER_BIT - 1) begin
                        clk_count <= clk_count + 1;
                    end else begin
                        clk_count <= 0;
                        rx_data[bit_index] <= RXD_i; // Próbkowanie bitu danych
                        
                        if (bit_index < 7) begin
                            bit_index <= bit_index + 1;
                        end else begin
                            bit_index <= 0;
                            state <= STOP;
                        end
                    end
                end
                STOP: begin
                    if(clk_count < CLKS_PER_BIT -1) begin
                        clk_count <= clk_count +1;
                    end 
                    else begin
                        rx_data_o <= rx_data;
                        rx_done_o <=1'b1;
                        state <= IDLE;
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end
endmodule
