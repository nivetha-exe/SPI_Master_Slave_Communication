module spi_slave (
    input  wire       reset,
    input  wire       cs,
    input  wire       sclk,
    input  wire       mosi,
    input  wire [7:0] data_in,

    output reg        miso,
    output reg [7:0]  data_out,
    output reg        done
);

    reg [7:0] rx_shift;
    reg [7:0] tx_shift;
    reg [2:0] bit_count;


    // =========================================
    // Reset / start of transaction
    // =========================================

    always @(posedge reset or negedge cs) begin

        if (reset) begin
            tx_shift <= 8'b0;
            miso     <= 1'b0;
        end

        else begin
            // Load transmit data when CS becomes active
            tx_shift <= {data_in[6:0], 1'b0};

            // First bit is available immediately
            miso <= data_in[7];
        end

    end


    // =========================================
    // RECEIVE
    // Mode 0: sample MOSI on rising edge
    // =========================================

    always @(posedge sclk or posedge reset or posedge cs) begin

        if (reset) begin
            rx_shift  <= 8'b0;
            data_out  <= 8'b0;
            bit_count <= 3'd0;
            done      <= 1'b0;
        end

        else if (cs) begin
            rx_shift  <= 8'b0;
            bit_count <= 3'd0;
            done      <= 1'b0;
        end

        else begin

            done <= 1'b0;

            rx_shift <= {rx_shift[6:0], mosi};

            if (bit_count == 3'd7) begin
                data_out <= {rx_shift[6:0], mosi};
                done <= 1'b1;
            end
            else begin
                bit_count <= bit_count + 1'b1;
            end

        end

    end


    // =========================================
    // TRANSMIT
    // Mode 0: change MISO on falling edge
    // =========================================

    always @(negedge sclk or posedge reset) begin

        if (reset) begin
            tx_shift <= 8'b0;
        end

        else if (!cs) begin

            miso <= tx_shift[7];

            tx_shift <= {tx_shift[6:0], 1'b0};

        end

    end

endmodule