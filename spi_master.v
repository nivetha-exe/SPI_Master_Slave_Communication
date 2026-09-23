module spi_master #(
    parameter CLK_DIV = 4
)(
    input  wire       clk,
    input  wire       reset,
    input  wire       start,
    input  wire [7:0] data_in,
    input  wire       miso,

    output reg        cs,
    output reg        sclk,
    output reg        mosi,
    output reg [7:0]  data_out,
    output reg        done
);

    reg [7:0] tx_data;
    reg [7:0] rx_data;

    reg [2:0] bit_count;
    reg [15:0] clk_count;

    reg busy;

    always @(posedge clk or posedge reset) begin

        if (reset) begin
            cs        <= 1'b1;
            sclk      <= 1'b0;
            mosi      <= 1'b0;
            data_out  <= 8'b0;
            done      <= 1'b0;

            tx_data   <= 8'b0;
            rx_data   <= 8'b0;
            bit_count <= 3'd0;
            clk_count <= 16'd0;
            busy      <= 1'b0;
        end

        else begin

            done <= 1'b0;

            // Start a new SPI transfer
            if (start && !busy) begin
                busy      <= 1'b1;
                cs        <= 1'b0;
                sclk      <= 1'b0;

                tx_data   <= data_in;
                rx_data   <= 8'b0;

                bit_count <= 3'd0;
                clk_count <= 16'd0;

                // First bit is placed on MOSI before first rising edge
                mosi      <= data_in[7];
            end

            else if (busy) begin

                if (clk_count == CLK_DIV - 1) begin

                    clk_count <= 16'd0;

                    // Rising edge: sample MISO
                    if (sclk == 1'b0) begin
                        sclk <= 1'b1;

                        rx_data[7 - bit_count] <= miso;
                    end

                    // Falling edge: prepare next MOSI bit
                    else begin
                        sclk <= 1'b0;

                        if (bit_count == 3'd7) begin
                            // Transfer complete
                            busy     <= 1'b0;
                            cs       <= 1'b1;
                            mosi     <= 1'b0;

                            data_out <= rx_data;
                            done     <= 1'b1;
                        end

                        else begin
                            bit_count <= bit_count + 1'b1;

                            mosi <= tx_data[6 - bit_count];
                        end
                    end
                end

                else begin
                    clk_count <= clk_count + 1'b1;
                end
            end
        end
    end

endmodule