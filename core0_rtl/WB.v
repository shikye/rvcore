module WB (
    input   wire                    clk,
    input   wire                    rst_n,

    //from mem_wb_reg
    input   wire            [31:0]  memwb_reg_wdata_i,
    input   wire            [4:0]   memwb_reg_waddr_i,
    input   wire                    memwb_reg_we_i,

    input   wire            [31:0]  memwb_csr_wdata_i,
    input   wire            [11:0]  memwb_csr_waddr_i,
    input   wire                    memwb_csr_we_i,
    //to regs
    output  wire            [31:0]  wb_reg_wdata_o,
    output  wire            [4:0]   wb_reg_waddr_o,
    output  wire                    wb_reg_we_o,

    output  wire            [31:0]  wb_csr_wdata_o,
    output  wire            [11:0]  wb_csr_waddr_o,
    output  wire                    wb_csr_we_o,

    //from fc
    input   wire                    fc_stall_wb_i
);

    assign wb_reg_wdata_o = memwb_reg_wdata_i;
    assign wb_reg_waddr_o = memwb_reg_waddr_i;
    assign wb_reg_we_o = fc_stall_wb_i ? 1'b0 : memwb_reg_we_i;

    assign wb_csr_wdata_o = memwb_csr_wdata_i;
    assign wb_csr_waddr_o = memwb_csr_waddr_i;
    assign wb_csr_we_o = fc_stall_wb_i ? 1'b0 : memwb_csr_we_i;
    

endmodule