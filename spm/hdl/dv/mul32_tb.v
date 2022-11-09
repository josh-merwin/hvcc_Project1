// A Serial-Parallel Multiplier (SPM)
// Modeled after the design outlined by shorturl.at/rwxGK
// Copyright 2016, mshalan@aucegypt.edu

`timescale          1ns/1ns

module mul32_tb;

    localparam CLK_PERIOD = 5;
    localparam RST_TIME = 555;

    //Registers to drive the Inputs
	reg clk;
	reg rst;
    reg start;
	reg [31: 0] mp;
    reg [31: 0] mc;
    
	//Wires to observe the Outputs
    wire        done;
	wire [31:0] p;

    // Dump all signals into "mul32_tb.vcd" during simulation
    initial begin
        $dumpfile("mul32_tb.vcd");
        $dumpvars;
    end

    // Initialize the drivers
    initial begin
        clk = 1'b0;
        rst = 1'b1;
        start = 1'b0;
        mp = 32'b0;
        mc = 32'b0;
    end

    // The clock signal
    always #(CLK_PERIOD/2) clk = ~clk;

    // The reset signal
    initial begin
        #RST_TIME;
        // deassert rst with the clock edge
        // to simulate the reset synchronizer
        @(posedge clk); 
        rst = 1'b0;
    end

    mul32 duv (
        .clk(clk),
        .rst(rst),
        .start(start),
        .mc(mc),
        .mp(mp),
        .p(p),
        .done(done)
    );

    // The checker
    always@(negedge clk)
        if(!rst & done)
            if( (mp*mc) != p ) begin
                $display("Test failed %0d x %0d = %0d, got %0d", mc, mp, mc*mp, p);
                //$finish;
            end else
                $display("%0d x %0d = %0d -- OK!", mc, mp, p);

    // The test code
    initial begin
        @(negedge rst);
        
        repeat (10) begin
            // some random values to multiply
            @(posedge clk);
            mp = $random & 32'hffff;
            mc = $random & 32'hffff;
            
            // Generate the start signal
            @(posedge clk);
            start = 1'b1;
            @(posedge clk);
            start = 1'b0;

            // wait for the multiplier to finish
            @(posedge done);
        end

        $finish;
    end

endmodule

    