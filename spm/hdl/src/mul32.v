// A Serial-Parallel Multiplier (SPM)
// Modeled after the design outlined by shorturl.at/rwxGK
// Copyright 2016, mshalan@aucegypt.edu

`timescale          1ns/1ns

`default_nettype    none

/*
    mul32 is a signed 32-bit multiplier that produces 32-bit product. it is implemented as a wrapper 
    around spm to provide parallel interfaces for the multiplier (mp), the multiplicand (mc) and the 
    product (p).
    
    As spm is a sequential multiplier, mul32, also, adds the control signal start to initiate 
    the multiplication. Also, it adds a status output (done) to flag the readiness of the product.
*/
module mul32 (
    input wire          clk,
    input wire          rst,
    input wire          start,
    input wire  [31:0]  mc,
    input wire  [31:0]  mp,
    output reg  [31:0]  p,
    output wire         done
);
    wire        pw;
    reg [31:0]  Y;
    reg [5:0]   cnt, ncnt;
    reg [1:0]   state, nstate;

    localparam  IDLE=0, RUNNING=1, DONE=2;

    always @(posedge clk or posedge rst)
        if(rst)
            state  <= IDLE;
        else 
            state <= nstate;
    
    always @*
        case(state)
            IDLE    :   if(start) nstate = RUNNING; else nstate = IDLE;
            RUNNING :   if(cnt == 32) nstate = DONE; else nstate = RUNNING; 
            DONE    :   nstate = IDLE;
            default :   nstate = IDLE;
        endcase
    
    always @(posedge clk)
        cnt <= ncnt;

    always @*
        case(state)
            IDLE    :   ncnt = 0;
            RUNNING :   ncnt = cnt + 1;
            DONE    :   ncnt = 0;
            default :   ncnt = 0;
        endcase

    always @(posedge clk or posedge rst)
        if(rst)
            Y <= 32'b0;
        else if((start == 1'b1))// && (state == IDLE))
            Y <= mp;
        else if(state==RUNNING) 
            Y <= (Y >> 1);

    always @(posedge clk)// or posedge rst)
        if(start)
            p <= 32'b0;
        else if(state==RUNNING)
            p <= {pw, p[31:1]};

    wire y = (state==RUNNING) ? Y[0] : 1'b0;

    spm #(.size(32)) spm32(
        .clk(clk),
        .rst(rst),
        .x(mc),
        .y(y),
        .p(pw)
    );

    assign done = (state == DONE);

endmodule

