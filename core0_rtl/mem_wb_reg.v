module mem_wb_reg (
    input   wire                    clk,
    input   wire                    rst_n,
    //from mem
    input   wire            [31:0]  mem_reg_wdata_i,
    input   wire            [4:0]   mem_reg_waddr_i,
    input   wire                    mem_reg_we_i,

    input   wire            [31:0]  mem_csr_wdata_i,
    input   wire            [11:0]  mem_csr_waddr_i,
    input   wire                    mem_csr_we_i,

    //to wb
    output  reg             [31:0]  memwb_reg_wdata_o,
    output  reg             [4:0]   memwb_reg_waddr_o,
    output  reg                     memwb_reg_we_o,

    output  reg             [31:0]  memwb_csr_wdata_o,
    output  reg             [11:0]  memwb_csr_waddr_o,
    output  reg                     memwb_csr_we_o,

    //from fc
    input   wire                    fc_flush_memwb_i,
    input   wire                    fc_stall_memwb_i
);



    always@(posedge clk or negedge rst_n)begin

        if(rst_n == 1'b0)begin
            memwb_reg_wdata_o <= 32'h0;
            memwb_reg_waddr_o <= 5'h0;
            memwb_reg_we_o <= 1'b0;

            memwb_csr_wdata_o <= 32'h0;
            memwb_csr_waddr_o <= 12'h0;
            memwb_csr_we_o <= 1'b0;

        end
        else if(fc_stall_memwb_i == 1'b1)begin
            memwb_reg_wdata_o <= memwb_reg_wdata_o;
            memwb_reg_waddr_o <= memwb_reg_waddr_o;
            memwb_reg_we_o <= memwb_reg_we_o;  

            memwb_csr_wdata_o <= memwb_csr_wdata_o;
            memwb_csr_waddr_o <= memwb_csr_waddr_o;
            memwb_csr_we_o <= memwb_csr_we_o;
        end
        else if(fc_flush_memwb_i == 1'b1)begin
            memwb_reg_wdata_o <= 32'h0;
            memwb_reg_waddr_o <= 5'h0;
            memwb_reg_we_o <= 1'b0;

            memwb_csr_wdata_o <= 32'h0;
            memwb_csr_waddr_o <= 12'h0;
            memwb_csr_we_o <= 1'b0;
        end
        else begin
            memwb_reg_wdata_o <= mem_reg_wdata_i;
            memwb_reg_waddr_o <= mem_reg_waddr_i;
            memwb_reg_we_o <= mem_reg_we_i;

            memwb_csr_wdata_o <= mem_csr_wdata_i;
            memwb_csr_waddr_o <= mem_csr_waddr_i;
            memwb_csr_we_o <= mem_csr_we_i;
        end
    end
    


endmodule