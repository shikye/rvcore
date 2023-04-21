`include "define.v"
module Data_Hazard_N_Forward(
    //from id
    input   wire            [4:0]   id_reg1_raddr_i,
    input   wire            [4:0]   id_reg2_raddr_i,
    input   wire                    id_reg1_RE_i,
    input   wire                    id_reg2_RE_i,

    input   wire            [11:0]  id_csr_raddr_i,
    input   wire                    id_csr_RE_i,

    //from ex
    input   wire            [4:0]   ex_reg_waddr_i,
    input   wire            [31:0]  ex_reg_wdata_i,
    input   wire                    ex_reg_we_i,

    input   wire            [11:0]  ex_csr_waddr_i,
    input   wire            [31:0]  ex_csr_wdata_i,
    input   wire                    ex_csr_we_i,
    //from mem
    input   wire            [4:0]   mem_reg_waddr_i,
    input   wire            [31:0]  mem_reg_wdata_i,
    input   wire                    mem_reg_we_i,

    input   wire            [11:0]  mem_csr_waddr_i,
    input   wire            [31:0]  mem_csr_wdata_i,
    input   wire                    mem_csr_we_i,
    //from wb
    input   wire            [4:0]   wb_reg_waddr_i,
    input   wire            [31:0]  wb_reg_wdata_i,
    input   wire                    wb_reg_we_i,

    input   wire            [11:0]  wb_csr_waddr_i,
    input   wire            [31:0]  wb_csr_wdata_i,
    input   wire                    wb_csr_we_i,
    //to id
    output  wire                    dhnf_harzard_sel1_o,
    output  wire                    dhnf_harzard_sel2_o,
    
    output  wire            [31:0]  dhnf_forward_data1_o,
    output  wire            [31:0]  dhnf_forward_data2_o,


    output  wire                    dhnf_harzard_csrsel_o,
    output  wire            [31:0]  dhnf_forward_csr_o


    //to clint
    // output  wire            [31:0]  dhnf_mstatus_o,
    // output  wire            [31:0]  dhnf_mtvec_o,
    // output  wire            [31:0]  dhnf_mepc_o,

    // output  wire                    dhnf_mstatus_sel_o,
    // output  wire                    dhnf_mtvec_sel_o,
    // output  wire                    dhnf_mepc_sel_o
);


    //1-hazard 0-nohazard
    wire    reg1_id_ex_hazard = (id_reg1_raddr_i != 5'b0) && id_reg1_RE_i && ex_reg_we_i &&    
        (id_reg1_raddr_i == ex_reg_waddr_i);


    wire    reg2_id_ex_hazard = (id_reg2_raddr_i != 5'b0) && id_reg2_RE_i && ex_reg_we_i && 
        (id_reg2_raddr_i == ex_reg_waddr_i);

    
    wire    reg1_id_mem_hazard = (id_reg1_raddr_i != 5'b0) && id_reg1_RE_i && mem_reg_we_i &&    
        (id_reg1_raddr_i == mem_reg_waddr_i);


    wire    reg2_id_mem_hazard = (id_reg2_raddr_i != 5'b0) && id_reg2_RE_i && mem_reg_we_i && 
        (id_reg2_raddr_i == mem_reg_waddr_i);

    wire    reg1_id_wb_hazard = (id_reg1_raddr_i != 5'b0) && id_reg1_RE_i && wb_reg_we_i &&    
        (id_reg1_raddr_i == wb_reg_waddr_i);


    wire    reg2_id_wb_hazard = (id_reg2_raddr_i != 5'b0) && id_reg2_RE_i && wb_reg_we_i && 
        (id_reg2_raddr_i == wb_reg_waddr_i);
    

    wire    csr_id_ex_hazard    = id_csr_RE_i && ex_csr_we_i && (id_csr_raddr_i == ex_csr_waddr_i);
    wire    csr_id_mem_hazard   = id_csr_RE_i && mem_csr_we_i && (id_csr_raddr_i == mem_csr_waddr_i);
    wire    csr_id_wb_hazard    = id_csr_RE_i && wb_csr_we_i && (id_csr_raddr_i == wb_csr_waddr_i);
    

    
    assign dhnf_harzard_sel1_o = reg1_id_ex_hazard | reg1_id_mem_hazard |
        reg1_id_wb_hazard;

    assign dhnf_harzard_sel2_o = reg2_id_ex_hazard | reg2_id_mem_hazard |
        reg2_id_wb_hazard;
    
    assign dhnf_harzard_csrsel_o = csr_id_ex_hazard | csr_id_mem_hazard |
        csr_id_wb_hazard;

    
    //notice the complex way
    assign dhnf_forward_data1_o = reg1_id_ex_hazard ? ex_reg_wdata_i : 
        reg1_id_mem_hazard ? mem_reg_wdata_i :
        reg1_id_wb_hazard ? wb_reg_wdata_i : 32'b0;

    assign dhnf_forward_data2_o = reg2_id_ex_hazard ? ex_reg_wdata_i : 
        reg2_id_mem_hazard ? mem_reg_wdata_i :
        reg2_id_wb_hazard ? wb_reg_wdata_i : 32'b0;
    
    assign dhnf_forward_csr_o = csr_id_ex_hazard ? ex_csr_wdata_i :
        csr_id_mem_hazard ? mem_csr_wdata_i :
        csr_id_wb_hazard ? wb_csr_wdata_i : 32'b0;

    //------clint
    // wire mstatus_ex_harzard = ex_csr_we_i && (`MSTATUS == ex_csr_waddr_i);
    // wire mstatus_mem_harzard = mem_csr_we_i && (`MSTATUS == mem_csr_waddr_i);
    // wire mstatus_wb_harzard = wb_csr_we_i && (`MSTATUS == wb_csr_waddr_i);

    // assign dhnf_mstatus_sel_o = mstatus_ex_harzard | mstatus_mem_harzard | mstatus_wb_harzard;
    // assign dhnf_mstatus_o = mstatus_ex_harzard ? ex_csr_wdata_i : mstatus_mem_harzard ? mem_csr_wdata_i :
    //     mstatus_wb_harzard ? wb_csr_wdata_i : 32'd0;


    // wire mtvec_ex_harzard = ex_csr_we_i && (`MTVEC == ex_csr_waddr_i);
    // wire mtvec_mem_harzard = mem_csr_we_i && (`MTVEC == mem_csr_waddr_i);
    // wire mtvec_wb_harzard = wb_csr_we_i && (`MTVEC == wb_csr_waddr_i);

    // assign dhnf_mtvec_sel_o = mtvec_ex_harzard | mtvec_mem_harzard | mtvec_wb_harzard;
    // assign dhnf_mtvec_o = mtvec_ex_harzard ? ex_csr_wdata_i : mtvec_mem_harzard ? mem_csr_wdata_i :
    //     mtvec_wb_harzard ? wb_csr_wdata_i : 32'd0;        

    
    // wire mepc_ex_harzard = ex_csr_we_i && (`MEPC == ex_csr_waddr_i);
    // wire mepc_mem_harzard = mem_csr_we_i && (`MEPC == mem_csr_waddr_i);
    // wire mepc_wb_harzard = wb_csr_we_i && (`MEPC == wb_csr_waddr_i);

    // assign dhnf_mepc_sel_o = mepc_ex_harzard | mepc_mem_harzard | mepc_wb_harzard;
    // assign dhnf_mepc_o = mepc_ex_harzard ? ex_csr_wdata_i : mepc_mem_harzard ? mem_csr_wdata_i :
    //     mepc_wb_harzard ? wb_csr_wdata_i : 32'd0;      


endmodule