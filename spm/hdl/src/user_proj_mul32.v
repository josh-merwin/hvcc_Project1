`default_nettype none

/*
    A user's project module for the mul32 design.

    mul32 is accessible over the wb bus as a slave from the management SoC.
    No usage of LA probes. Also, no I/O pads are used.
*/

module user_proj_mul32 
(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);
    wire start;
    wire done;
    
    //  WB Interface
    //  3 32 regsisters:
    //  MP  (RW)    0x00 
    //  MC  (RW)    0x04
    //  P   (RO)    0x08
    reg  [31:0]         MP, MC;
    wire [31:0]         P;
    wire                valid           = wbs_stb_i & wbs_cyc_i;
    wire                we              = wbs_we_i && valid;
    wire                re              = ~wbs_we_i && valid;
    wire [3:0]          byte_wr_en      = wbs_sel_i & {4{we}}; 
    wire                we_mp_reg       = we & (wbs_adr_i[7:0] == 8'h00);
    wire                we_mc_reg       = we & (wbs_adr_i[7:0] == 8'h04);
    wire                re_mp_reg       = re & (wbs_adr_i[7:0] == 8'h00);
    wire                re_mc_reg       = re & (wbs_adr_i[7:0] == 8'h04);
    wire                re_p_reg        = re & (wbs_adr_i[7:0] == 8'h08);
    
    always @(posedge wb_clk_i or posedge wb_rst_i)
        if(wb_rst_i)
            MP <= 32'h0;
        else if(we_mp_reg) 
            MP <= wbs_dat_i;
      
    always @(posedge wb_clk_i or posedge wb_rst_i)
        if(wb_rst_i)
            MC <= 32'h0;
        else if(we_mc_reg) 
            MC <= wbs_dat_i;
    
    assign      wbs_dat_o   =   (re_p_reg)  ?   P   :
                                (re_mp_reg) ?   MP  :
                                (re_mc_reg) ?   MC  :
                                32'hDEADBEEF;

    assign      wbs_ack_o   =   re_p_reg    ?   done    :   wbs_stb_i;

    reg         dly_re_p_reg;
    always @(posedge wb_clk_i) 
        dly_re_p_reg <= re_p_reg;

    assign      start       =      re_p_reg & ~dly_re_p_reg;

    // IO
    // Not used

    // LA
    // Not used

    // IRQ
    assign irq = 3'b000;	// Unused

    mul32 mul (
        .clk(wb_clk_i),
        .rst(wb_rst_i),
        .start(start),
        .mc(MC),
        .mp(MP),
        .p(P),
        .done(done)
    );

endmodule