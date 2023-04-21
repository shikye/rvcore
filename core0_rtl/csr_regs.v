`include "define.v"
module csr_regs(                                                    //read asyn, write syn
    input   wire                    clk,
    input   wire                    rst_n,

    //from id_stage
    input   wire            [11:0]  id_csr_raddr_i,

    //to id_stage
    output  reg             [31:0]  csr_regs_rdata_o,

    //from clint
    input   wire            [11:0]  cl_csr_waddr_i,
    input   wire            [31:0]  cl_csr_wdata_i,
    input   wire                    cl_csr_we_i,  
    
    //to clint
    output  wire            [31:0]  mstatus_o,
    output  wire            [31:0]  mtvec_o,
    output  wire            [31:0]  mepc_o,

    //from wb_stage         
    input   wire            [31:0]  wb_csr_wdata_i,
    input   wire            [11:0]  wb_csr_waddr_i,
    input   wire                    wb_csr_we_i
);


    assign mstatus_o = mstatus;
    assign mtvec_o = mtvec;
    assign mepc_o = mepc;


    reg [63:0]  mcycle;
    reg [31:0]  mstatus;
    reg [31:0]  mie;
    reg [31:0]  mtvec;
    reg [31:0]  mscratch;
    reg [31:0]  mepc;
    reg [31:0]  mcause;  

    always@(posedge clk) begin
        if(rst_n == 1'b0)
            mcycle <= 64'h0;
        else    
            mcycle <= mcycle + 64'd1;
    end


    always@(posedge clk)begin   //write
        if(rst_n == 1'b0)begin
            mstatus     <= 32'h0;   
            mie         <= 32'h0;   
            mtvec       <= 32'h0;   
            mscratch    <= 32'h0;   
            mepc        <= 32'h0;   
            mcause      <= 32'h0;   
        end
        else if(cl_csr_we_i == 1'b1) begin
            case(cl_csr_waddr_i)
                `MSTATUS:
                    mstatus <= cl_csr_wdata_i;
                `MIE:
                    mie     <= cl_csr_wdata_i;
                `MTVEC:
                    mtvec   <= cl_csr_wdata_i;
                `MSCRATCH:
                    mscratch<= cl_csr_wdata_i;
                `MEPC:
                    mepc    <= cl_csr_wdata_i;
                `MCAUSE:
                    mcause  <= cl_csr_wdata_i;
                default:;
            endcase
        end

        else if(wb_csr_we_i == 1'b1) begin
            case(wb_csr_waddr_i)
                `MSTATUS:
                    mstatus <= wb_csr_wdata_i;
                `MIE:
                    mie     <= wb_csr_wdata_i;
                `MTVEC:
                    mtvec   <= wb_csr_wdata_i;
                `MSCRATCH:
                    mscratch<= wb_csr_wdata_i;
                `MEPC:
                    mepc    <= wb_csr_wdata_i;
                `MCAUSE:
                    mcause  <= wb_csr_wdata_i;
                default:;
            endcase
        end
    end



    always @(*) begin
        case(id_csr_raddr_i)
            `MSTATUS:
                csr_regs_rdata_o = mstatus;
            `MIE:
                csr_regs_rdata_o = mie;
            `MTVEC:
                csr_regs_rdata_o = mtvec;
            `MSCRATCH:
                csr_regs_rdata_o = mscratch;
            `MEPC:
                csr_regs_rdata_o = mepc;
            `MCAUSE:
                csr_regs_rdata_o = mcause;
            default:csr_regs_rdata_o = 32'h0;
        endcase
    end




endmodule