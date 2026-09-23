`timescale 1ns/1ps

module spi_master_slave_tb;

    // =========================================
    // Master signals
    // =========================================

    reg        clk;
    reg        reset;
    reg        start;
    reg [7:0]  master_data_in;

    wire       cs;
    wire       sclk;
    wire       mosi;
    wire       miso;
    wire [7:0] master_data_out;
    wire       master_done;


    // =========================================
    // Slave signals
    // =========================================

    reg [7:0] slave_data_in;

    wire [7:0] slave_data_out;
    wire       slave_done;


    // =========================================
    // SPI MASTER
    // =========================================

    spi_master #(
        .CLK_DIV(4)
    ) master (
        .clk      (clk),
        .reset    (reset),
        .start    (start),
        .data_in  (master_data_in),
        .miso     (miso),

        .cs       (cs),
        .sclk     (sclk),
        .mosi     (mosi),
        .data_out (master_data_out),
        .done     (master_done)
    );


    // =========================================
    // SPI SLAVE
    // =========================================

    spi_slave slave (
        .reset    (reset),
        .cs       (cs),
        .sclk     (sclk),
        .mosi     (mosi),
        .data_in  (slave_data_in),

        .miso     (miso),
        .data_out (slave_data_out),
        .done     (slave_done)
    );


    // =========================================
    // System clock
    // 10 ns period
    // =========================================

    always #5 clk = ~clk;


    // =========================================
    // TEST
    // =========================================

    initial begin

        // Initial values
        clk            = 1'b0;
        reset          = 1'b1;
        start          = 1'b0;

        master_data_in = 8'b0;
        slave_data_in  = 8'b0;


        // -----------------------------------------
        // Reset
        // -----------------------------------------

        #20;
        reset = 1'b0;


        // -----------------------------------------
        // Data to exchange
        // -----------------------------------------

        // Master sends this to Slave
        master_data_in = 8'b10110010;

        // Slave sends this to Master
        slave_data_in  = 8'b11001010;


        // -----------------------------------------
        // Start SPI communication
        // -----------------------------------------

        #10;
        start = 1'b1;

        #10;
        start = 1'b0;


        // -----------------------------------------
        // Wait for Master to finish
        // -----------------------------------------

        @(posedge master_done);

        // Allow non-blocking assignments to settle
        #1;


        // -----------------------------------------
        // Display results
        // -----------------------------------------

        $display("--------------------------------------------");
        $display("SPI MASTER + SLAVE TEST");
        $display("--------------------------------------------");

        $display("Master TX       = %b", master_data_in);
        $display("Slave RX        = %b", slave_data_out);

        $display("Slave TX        = %b", slave_data_in);
        $display("Master RX       = %b", master_data_out);

        $display("--------------------------------------------");


        // =========================================
        // CHECK MASTER → SLAVE
        // =========================================

        if (slave_data_out == master_data_in)
            $display("MASTER -> SLAVE : PASS");
        else
            $display("MASTER -> SLAVE : FAIL");


        // =========================================
        // CHECK SLAVE → MASTER
        // =========================================

        if (master_data_out == slave_data_in)
            $display("SLAVE -> MASTER : PASS");
        else
            $display("SLAVE -> MASTER : FAIL");


        // =========================================
        // FINAL RESULT
        // =========================================

        if ((slave_data_out == master_data_in) &&
            (master_data_out == slave_data_in))
            $display("SPI MASTER-SLAVE TEST: PASSED!");
        else
            $display("SPI MASTER-SLAVE TEST: FAILED!");


        $display("--------------------------------------------");


        #20;
        $finish;

    end

endmodule