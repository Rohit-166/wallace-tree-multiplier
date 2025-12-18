`timescale 1ns/1ps
// ================================================================
// Testbench for Wallace Multiplier (16x16 -> 32-bit)
// Self-checking with random test vectors
// ================================================================

module tb_wallace_multiplier;

    // Clock and reset
    reg clk;
    reg rst;

    // Inputs
    reg  [15:0] a, b;

    // DUT output
    wire [31:0] p;

    // Instantiate DUT
    wallace_multiplier DUT (
        .clk(clk),
        .rst(rst),
        .a(a),
        .b(b),
        .p(p)
    );

    // Clock generation: 10ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset sequence
    initial begin
        rst = 1;
        #20;
        rst = 0;
    end

    // ============================================================
    // Self-checking logic
    // ============================================================
    integer i;
    reg [31:0] expected;
    integer errors = 0;

    // Pipeline delay (matches number of registered stages)
    // Wallace tree here has 3 pipeline stages
    localparam PIPELINE_LAT = 5;

    // FIFO for expected outputs (to match pipeline delay)
    reg [31:0] exp_pipe [0:PIPELINE_LAT];
    integer d;

    initial begin
        // Initialize
        for (d = 0; d <= PIPELINE_LAT; d = d + 1)
            exp_pipe[d] = 0;

        @(negedge rst); // wait until reset deasserted
        @(posedge clk);

        // Apply 20 random test cases
        for (i = 0; i < 20; i = i + 1) begin
            a = $random;
            b = $random;
            expected = a * b;

            // Shift pipeline reference values
            exp_pipe[0] = expected;
            for (d = PIPELINE_LAT; d > 0; d = d - 1)
                exp_pipe[d] = exp_pipe[d - 1];

            @(posedge clk);

            // Compare when pipeline is filled
            if (i >= PIPELINE_LAT) begin
                if (p !== exp_pipe[PIPELINE_LAT]) begin
                    $display("? MISMATCH @ time %t: a=%d b=%d => DUT=%d, expected=%d",
                             $time, a, b, p, exp_pipe[PIPELINE_LAT]);
                    errors = errors + 1;
                end else begin
                    $display("? PASS @ time %t: a=%d b=%d => %d",
                             $time, a, b, p);
                end
            end
        end

        // Wait extra cycles to flush pipeline
        repeat(PIPELINE_LAT+2) @(posedge clk);

        $display("\n================================================");
        if (errors == 0)
            $display("? All test cases passed!");
        else
            $display("? %0d mismatches found!", errors);
        $display("================================================\n");
    end

endmodule



