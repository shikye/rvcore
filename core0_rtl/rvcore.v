module rvcore(
    input   wire                    clk,
    input   wire                    rst_n,

    //from interface
    input   wire            [127:0] axi_data_i,  //to axi controller
    input   wire                    axi_rd_over_i,
    input   wire                    axi_wr_over_i,
    input   wire                    core_WAIT_i,

    //to interface
    output  wire                     Rvcore_valid_req_o,
    output  wire                     Rvcore_rw_o,
    output  wire             [31:0]  Rvcore_addr_o,
    output  wire             [127:0] Rvcore_data_o
);



assign Rvcore_valid_req_o = bc_valid_req_o;    
assign Rvcore_rw_o = bc_rw_o;
assign Rvcore_addr_o = bc_addr_o;    
assign Rvcore_data_o = bc_data_o;

    //source 
    //IF
    wire    [31:0]  if_pc_o;

    wire            if_req_Icache_o;

    //if_id_reg
    wire    [31:0]  ifid_pc_o;

    //ID
    
    wire    [4:0]   id_reg1_raddr_o;
    wire    [4:0]   id_reg2_raddr_o;

    wire    [31:0]  id_op_a_o;
    wire    [31:0]  id_op_b_o;

    wire    [4:0]   id_reg_waddr_o;
    wire            id_reg_we_o;

    wire    [4:0]   id_ALUctrl_o;

    wire            id_btype_flag_o;
    wire    [31:0]  id_btype_jump_pc_o;

    wire            id_mtype_o;  
    wire            id_mem_rw_o;  
    wire    [1:0]   id_mem_width_o; 
    wire    [31:0]  id_mem_wr_data_o;
    wire            id_mem_rdtype_o;  

    wire            id_reg1_RE_o;
    wire            id_reg2_RE_o;

    wire            id_jump_flag_o;
    wire    [31:0]  id_jump_pc_o;

    wire            id_load_use_flag_o;
    
    wire    [11:0]  id_csr_raddr_o;
    wire            id_csr_RE_o;

    wire            id_csr_we_o;
    wire    [11:0]  id_csr_waddr_o;
    wire    [31:0]  id_csr_rdata_o;
    

    //id_ex_reg
    wire    [31:0]  idex_op_a_o;
    wire    [31:0]  idex_op_b_o;
    wire    [4:0]   idex_reg_waddr_o;
    wire            idex_reg_we_o;
    
    wire            idex_csr_we_o;
    wire    [11:0]  idex_csr_waddr_o;  
    wire    [31:0]  idex_csr_rdata_o;
    
    wire    [4:0]   idex_ALUctrl_o;
    wire            idex_btype_flag_o;
    wire    [31:0]  idex_btype_jump_pc_o;

    wire            idex_mtype_o;          
    wire            idex_mem_rw_o;          
    wire    [1:0]   idex_mem_width_o;      
    wire    [31:0]  idex_mem_wr_data_o;   
    wire            idex_mem_rdtype_o;  

    //EX
    wire     [31:0] ex_reg_wdata_o;
    wire     [4:0]  ex_reg_waddr_o;
    wire            ex_reg_we_o;

    wire     [31:0] ex_csr_wdata_o;
    wire     [11:0] ex_csr_waddr_o;
    wire            ex_csr_we_o;

    wire            ex_mtype_o;  
    wire            ex_mem_rw_o; 
    wire     [1:0]  ex_mem_width_o;

    wire            ex_req_Dcache_o;  

    wire     [31:0] ex_mem_wr_data_o;
    wire     [1:0]  ex_mem_wrwidth_o;
    wire     [31:0] ex_mem_addr_o;
    wire            ex_mem_rdtype_o;

    wire            ex_branch_flag_o;
    wire     [31:0] ex_branch_pc_o;

    wire            ex_req_bus_o;

    //ex_mem_reg
    wire     [31:0]  exmem_reg_wdata_o;
    wire     [4:0]   exmem_reg_waddr_o;
    wire             exmem_reg_we_o;

    wire     [31:0]  exmem_csr_wdata_o;
    wire     [11:0]  exmem_csr_waddr_o;
    wire             exmem_csr_we_o;


    wire             exmem_mtype_o;          
    wire             exmem_mem_rw_o;        
    wire     [1:0]   exmem_mem_width_o;    
    wire     [31:0]  exmem_mem_addr_o;
    wire             exmem_mem_rdtype_o;
    //MEM
    wire     [31:0]  mem_reg_wdata_o;
    wire     [4:0]   mem_reg_waddr_o;
    wire             mem_reg_we_o;
    
    wire     [31:0]  mem_csr_wdata_o;
    wire     [11:0]  mem_csr_waddr_o;
    wire             mem_csr_we_o;

    //mem_wb_reg
    wire     [31:0]  memwb_reg_wdata_o;
    wire     [4:0]   memwb_reg_waddr_o;
    wire             memwb_reg_we_o;

    wire     [31:0]  memwb_csr_wdata_o;
    wire     [11:0]  memwb_csr_waddr_o;
    wire             memwb_csr_we_o;


    //WB
    wire     [31:0]  wb_reg_wdata_o;
    wire     [4:0]   wb_reg_waddr_o;
    wire             wb_reg_we_o;

    wire     [31:0]  wb_csr_wdata_o;
    wire     [11:0]  wb_csr_waddr_o;
    wire             wb_csr_we_o;


    //dhnf
    wire             dhnf_harzard_sel1_o;
    wire             dhnf_harzard_sel2_o;

    wire     [31:0]  dhnf_forward_data1_o;
    wire     [31:0]  dhnf_forward_data2_o;

    wire             dhnf_harzard_csrsel_o;
    wire     [31:0]  dhnf_forward_csr_o;

    //regs
    wire     [31:0]  regs_reg1_rdata_o;
    wire     [31:0]  regs_reg2_rdata_o;

    //Icache
    wire     [31:0]  Icache_inst_o;

    wire             Icache_ready_o;
    wire             Icache_hit_o;

    wire     [31:0]  Icache_addr_o;
    wire             Icache_valid_req_o;

    //Dcache
    wire     [31:0]  Dcache_data_o;  

    wire             Dcache_ready_o;   
    wire             Dcache_hit_o;

    wire             Dcache_rd_req_o; 
    wire     [31:0]  Dcache_rd_addr_o;

    wire             Dcache_wb_req_o;
    wire     [31:0]  Dcache_wb_addr_o;
    wire     [127:0] Dcache_wb_data_o;

    //FC
    wire             fc_flush_ifid_o;
    wire             fc_flush_idex_o;
    wire             fc_flush_exmem_o;
    wire             fc_flush_memwb_o;
    wire             fc_flush_id_o;
    wire             fc_flush_ex_o;
    wire             fc_flush_mem_o;
    
    wire     [31:0]  fc_jump_pc_if_o;
    wire             fc_jump_flag_if_o;
    wire             fc_jump_flag_Icache_o;
    
    wire             fc_stall_if_o;
    wire             fc_stall_id_o;
    wire             fc_stall_ex_o;
    wire             fc_stall_wb_o;
    wire             fc_stall_mem_o;
    wire             fc_stall_Icache_o;

    wire             fc_stall_ifid_o;
    wire             fc_stall_idex_o;
    wire             fc_stall_exmem_o;
    wire             fc_stall_memwb_o;

    //csr_regs
    wire        [31:0]  csr_regs_rdata_o;

    //axi_m_interface
    wire        [127:0] axi_data_o;
    wire                axi_rd_over_o;
    wire                axi_wr_over_o;
    wire                core_WAIT_m_o;

    wire    [1-1 : 0]                M_AXI_AWID;
    wire    [32-1 : 0]                M_AXI_AWADDR;
    wire    [3 : 0]                         M_AXI_AWLEN;
    wire    [2 : 0]                         M_AXI_AWSIZE;
    wire    [1 : 0]                         M_AXI_AWBURST;
    wire                                    M_AXI_AWVALID;

    wire    [32-1 : 0]                M_AXI_WDATA;
    wire    [32/8-1 : 0]              M_AXI_WSTRB;
    wire                                    M_AXI_WLAST;
    wire                                    M_AXI_WVALID;

    wire                                    M_AXI_BREADY;

    wire    [1-1 : 0]                M_AXI_ARID;
    wire    [32-1 : 0]                M_AXI_ARADDR;
    wire    [3 : 0]                         M_AXI_ARLEN;
    wire    [2 : 0]                         M_AXI_ARSIZE;
    wire    [1 : 0]                         M_AXI_ARBURST;
    wire                                    M_AXI_ARVALID;

    wire                                    M_AXI_RREADY;


    //bus_controller
    wire                                    bc_Icache_ready_o;
    wire    [127:0]                         bc_Icache_data_o;
    wire                                    bc_Dcache_ready_o;
    wire    [127:0]                         bc_Dcache_data_o;
    wire                                    bc_valid_req_o;
    wire                                    bc_rw_o;
    wire    [31:0]                          bc_addr_o;
    wire    [127:0]                         bc_data_o;
    wire                                    core_WAIT_bus_o; 

    wire                                    bc_bus_ready_o;
    wire    [31:0]                          bc_bus_data_o;



    IF IF_ins(
        .clk(clk),
        .rst_n(rst_n),

        .fc_stall_if_i(fc_stall_if_o),

        .fc_jump_pc_if_i(fc_jump_pc_if_o),
        .fc_jump_flag_if_i(fc_jump_flag_if_o),

        .if_pc_o(if_pc_o),

        .if_req_Icache_o(if_req_Icache_o)
    );


    if_id_reg ifid_ins(
        .clk(clk),
        .rst_n(rst_n),

        .if_pc_i(if_pc_o),

        .fc_flush_ifid_i(fc_flush_ifid_o),
        .fc_stall_ifid_i(fc_stall_ifid_o),

        .ifid_pc_o(ifid_pc_o)
    );

    ID ID_ins(
        .clk(clk),
        .rst_n(rst_n),

        .ifid_pc_i(ifid_pc_o),

        .regs_reg1_rdata_i(regs_reg1_rdata_o),
        .regs_reg2_rdata_i(regs_reg2_rdata_o),

        .id_reg1_raddr_o(id_reg1_raddr_o),
        .id_reg2_raddr_o(id_reg2_raddr_o),

        .id_op_a_o(id_op_a_o),
        .id_op_b_o(id_op_b_o),

        .id_reg_waddr_o(id_reg_waddr_o),
        .id_reg_we_o(id_reg_we_o),

        .id_ALUctrl_o(id_ALUctrl_o),

        .id_btype_flag_o(id_btype_flag_o),
        .id_btype_jump_pc_o(id_btype_jump_pc_o),

        .id_mtype_o(id_mtype_o),
        .id_mem_rw_o(id_mem_rw_o),
        .id_mem_width_o(id_mem_width_o),
        .id_mem_wr_data_o(id_mem_wr_data_o),
        .id_mem_rdtype_o(id_mem_rdtype_o),

        .dhnf_harzard_sel1_i(dhnf_harzard_sel1_o),
        .dhnf_harzard_sel2_i(dhnf_harzard_sel2_o),
        .dhnf_forward_data1_i(dhnf_forward_data1_o),
        .dhnf_forward_data2_i(dhnf_forward_data2_o),

        .id_reg1_RE_o(id_reg1_RE_o),
        .id_reg2_RE_o(id_reg2_RE_o),

        .Icache_ready_i(Icache_ready_o),
        .Icache_inst_i(Icache_inst_o),

        .fc_flush_id_i(fc_flush_id_o),
        .fc_stall_id_i(fc_stall_id_o),

        .id_jump_flag_o(id_jump_flag_o),
        .id_jump_pc_o(id_jump_pc_o),
        
        .id_load_use_flag_o(id_load_use_flag_o),

        .id_csr_raddr_o(id_csr_raddr_o),
        .id_csr_RE_o(id_csr_RE_o),

        .csr_regs_rdata_i(csr_regs_rdata_o),

        .dhnf_harzard_csrsel_i(dhnf_harzard_csrsel_o),
        .dhnf_forward_csr_i(dhnf_forward_csr_o),

        .id_csr_we_o(id_csr_we_o),
        .id_csr_waddr_o(id_csr_waddr_o),
        .id_csr_rdata_o(id_csr_rdata_o)
    );


    id_ex_reg idex_ins(
        .clk(clk),
        .rst_n(rst_n),

        .id_op_a_i(id_op_a_o),
        .id_op_b_i(id_op_b_o),
        .id_reg_waddr_i(id_reg_waddr_o),
        .id_reg_we_i(id_reg_we_o),

        .id_ALUctrl_i(id_ALUctrl_o),
        .id_btype_flag_i(id_btype_flag_o),
        .id_btype_jump_pc_i(id_btype_jump_pc_o),

        .id_mtype_i(id_mtype_o),  
        .id_mem_rw_i(id_mem_rw_o), 
        .id_mem_width_i(id_mem_width_o),
        .id_mem_wr_data_i(id_mem_wr_data_o),
        .id_mem_rdtype_i(id_mem_rdtype_o),

        .id_csr_we_i(id_csr_we_o),
        .id_csr_waddr_i(id_csr_waddr_o),
        .id_csr_rdata_i(id_csr_rdata_o),

        .idex_op_a_o(idex_op_a_o),
        .idex_op_b_o(idex_op_b_o),
        .idex_reg_waddr_o(idex_reg_waddr_o),
        .idex_reg_we_o(idex_reg_we_o),


        .idex_csr_we_o(idex_csr_we_o),
        .idex_csr_waddr_o(idex_csr_waddr_o),
        .idex_csr_rdata_o(idex_csr_rdata_o),        

        .idex_ALUctrl_o(idex_ALUctrl_o),
        .idex_btype_flag_o(idex_btype_flag_o),
        .idex_btype_jump_pc_o(idex_btype_jump_pc_o),

        .idex_mtype_o(idex_mtype_o),          
        .idex_mem_rw_o(idex_mem_rw_o),          
        .idex_mem_width_o(idex_mem_width_o),      
        .idex_mem_wr_data_o(idex_mem_wr_data_o),   
        .idex_mem_rdtype_o(idex_mem_rdtype_o),   

        .fc_flush_idex_i(fc_flush_idex_o),
        .fc_stall_idex_i(fc_stall_idex_o)
    );

    EX EX_ins(
        .clk(clk),
        .rst_n(rst_n),

        .idex_op_a_i(idex_op_a_o),
        .idex_op_b_i(idex_op_b_o),
        .idex_reg_waddr_i(idex_reg_waddr_o),
        .idex_reg_we_i(idex_reg_we_o),

        .idex_ALUctrl_i(idex_ALUctrl_o),
        .idex_btype_flag_i(idex_btype_flag_o),
        .idex_btype_jump_pc_i(idex_btype_jump_pc_o),

        .idex_mtype_i(idex_mtype_o),          
        .idex_mem_rw_i(idex_mem_rw_o),          
        .idex_mem_width_i(idex_mem_width_o),      
        .idex_mem_wr_data_i(idex_mem_wr_data_o),   
        .idex_mem_rdtype_i(idex_mem_rdtype_o),  

        .idex_csr_we_i(idex_csr_we_o),
        .idex_csr_waddr_i(idex_csr_waddr_o),
        .idex_csr_rdata_i(idex_csr_rdata_o),        

        .ex_reg_wdata_o(ex_reg_wdata_o),
        .ex_reg_waddr_o(ex_reg_waddr_o),
        .ex_reg_we_o(ex_reg_we_o),

        .ex_csr_wdata_o(ex_csr_wdata_o),
        .ex_csr_waddr_o(ex_csr_waddr_o),
        .ex_csr_we_o(ex_csr_we_o),

        .ex_mtype_o(ex_mtype_o),  
        .ex_mem_rw_o(ex_mem_rw_o), 
        .ex_mem_width_o(ex_mem_width_o),
        .ex_mem_rdtype_o(ex_mem_rdtype_o),

        .ex_req_Dcache_o(ex_req_Dcache_o),

        .ex_mem_wr_data_o(ex_mem_wr_data_o),
        .ex_mem_wrwidth_o(ex_mem_wrwidth_o),
        .ex_mem_addr_o(ex_mem_addr_o),

        .ex_branch_flag_o(ex_branch_flag_o),
        .ex_branch_pc_o(ex_branch_pc_o),

        .fc_stall_ex_i(fc_stall_ex_o),

        .ex_req_bus_o(ex_req_bus_o)

    );


    ex_mem_reg exmem_ins(
        .clk(clk),
        .rst_n(rst_n),

        .ex_reg_wdata_i(ex_reg_wdata_o),
        .ex_reg_waddr_i(ex_reg_waddr_o),
        .ex_reg_we_i(ex_reg_we_o),

        .ex_csr_wdata_i(ex_csr_wdata_o),
        .ex_csr_waddr_i(ex_csr_waddr_o),
        .ex_csr_we_i(ex_csr_we_o),

        .ex_mtype_i(ex_mtype_o),  
        .ex_mem_rw_i(ex_mem_rw_o), 
        .ex_mem_width_i(ex_mem_width_o),
        .ex_mem_addr_i(ex_mem_addr_o),
        .ex_mem_rdtype_i(ex_mem_rdtype_o),

        .exmem_reg_wdata_o(exmem_reg_wdata_o),
        .exmem_reg_waddr_o(exmem_reg_waddr_o),
        .exmem_reg_we_o(exmem_reg_we_o),

        .exmem_csr_wdata_o(exmem_csr_wdata_o),
        .exmem_csr_waddr_o(exmem_csr_waddr_o),
        .exmem_csr_we_o(exmem_csr_we_o),

        .exmem_mtype_o(exmem_mtype_o),          
        .exmem_mem_rw_o(exmem_mem_rw_o),        
        .exmem_mem_width_o(exmem_mem_width_o),      
        .exmem_mem_addr_o(exmem_mem_addr_o),
        .exmem_mem_rdtype_o(exmem_mem_rdtype_o),

        .fc_flush_exmem_i(fc_flush_exmem_o),
        .fc_stall_exmem_i(fc_stall_exmem_o)
    );

    MEM MEM_ins(
        .clk(clk),
        .rst_n(rst_n),

        .exmem_reg_wdata_i(exmem_reg_wdata_o),
        .exmem_reg_waddr_i(exmem_reg_waddr_o),
        .exmem_reg_we_i(exmem_reg_we_o),

        .exmem_csr_wdata_i(exmem_csr_wdata_o),
        .exmem_csr_waddr_i(exmem_csr_waddr_o),
        .exmem_csr_we_i(exmem_csr_we_o),

        .exmem_mtype_i(exmem_mtype_o),          
        .exmem_mem_rw_i(exmem_mem_rw_o),        
        .exmem_mem_width_i(exmem_mem_width_o),    
        .exmem_mem_addr_i(exmem_mem_addr_o),  
        .exmem_mem_rdtype_i(exmem_mem_rdtype_o),

        .mem_reg_wdata_o(mem_reg_wdata_o),
        .mem_reg_waddr_o(mem_reg_waddr_o),
        .mem_reg_we_o(mem_reg_we_o),

        .mem_csr_wdata_o(mem_csr_wdata_o),
        .mem_csr_waddr_o(mem_csr_waddr_o),
        .mem_csr_we_o(mem_csr_we_o),

        .Dcache_ready_i(Dcache_ready_o),
        .Dcache_data_i(Dcache_data_o),

        .fc_stall_mem_i(fc_stall_mem_o),
        .fc_flush_mem_i(fc_flush_mem_o),

        .bc_bus_ready_i(bc_bus_ready_o),
        .bc_bus_data_i(bc_bus_data_o)

    );

    mem_wb_reg memwb_ins(
        .clk(clk),
        .rst_n(rst_n),

        .mem_reg_wdata_i(mem_reg_wdata_o),
        .mem_reg_waddr_i(mem_reg_waddr_o),
        .mem_reg_we_i(mem_reg_we_o),

        .mem_csr_wdata_i(mem_csr_wdata_o),
        .mem_csr_waddr_i(mem_csr_waddr_o),
        .mem_csr_we_i(mem_csr_we_o),

        .memwb_reg_wdata_o(memwb_reg_wdata_o),
        .memwb_reg_waddr_o(memwb_reg_waddr_o),
        .memwb_reg_we_o(memwb_reg_we_o),

        .memwb_csr_wdata_o(memwb_csr_wdata_o),
        .memwb_csr_waddr_o(memwb_csr_waddr_o),
        .memwb_csr_we_o(memwb_csr_we_o),

        .fc_flush_memwb_i(fc_flush_memwb_o),
        .fc_stall_memwb_i(fc_stall_memwb_o)
    );

    WB WB_ins(
        .clk(clk),
        .rst_n(rst_n),

        .memwb_reg_wdata_i(memwb_reg_wdata_o),
        .memwb_reg_waddr_i(memwb_reg_waddr_o),
        .memwb_reg_we_i(memwb_reg_we_o),

        .memwb_csr_wdata_i(memwb_csr_wdata_o),
        .memwb_csr_waddr_i(memwb_csr_waddr_o),
        .memwb_csr_we_i(memwb_csr_we_o),

        .wb_reg_wdata_o(wb_reg_wdata_o),
        .wb_reg_waddr_o(wb_reg_waddr_o),
        .wb_reg_we_o(wb_reg_we_o),

        .wb_csr_wdata_o(wb_csr_wdata_o),
        .wb_csr_waddr_o(wb_csr_waddr_o),
        .wb_csr_we_o(wb_csr_we_o),

        .fc_stall_wb_i(fc_stall_wb_o)
    );

    Data_Hazard_N_Forward dhnf_ins(
        .id_reg1_raddr_i(id_reg1_raddr_o),
        .id_reg2_raddr_i(id_reg2_raddr_o),
        .id_reg1_RE_i(id_reg1_RE_o),
        .id_reg2_RE_i(id_reg2_RE_o),

        .id_csr_raddr_i(id_csr_raddr_o),
        .id_csr_RE_i(id_csr_RE_o),

        .ex_reg_waddr_i(ex_reg_waddr_o),
        .ex_reg_wdata_i(ex_reg_wdata_o),
        .ex_reg_we_i(ex_reg_we_o),

        .ex_csr_waddr_i(ex_csr_waddr_o),
        .ex_csr_wdata_i(ex_csr_wdata_o),
        .ex_csr_we_i(ex_csr_we_o),

        .mem_reg_waddr_i(mem_reg_waddr_o),
        .mem_reg_wdata_i(mem_reg_wdata_o),
        .mem_reg_we_i(mem_reg_we_o),

        .mem_csr_waddr_i(mem_csr_waddr_o),
        .mem_csr_wdata_i(mem_csr_wdata_o),
        .mem_csr_we_i(mem_csr_we_o),

        .wb_reg_waddr_i(wb_reg_waddr_o),
        .wb_reg_wdata_i(wb_reg_wdata_o),
        .wb_reg_we_i(wb_reg_we_o),

        .wb_csr_waddr_i(wb_csr_waddr_o),
        .wb_csr_wdata_i(wb_csr_wdata_o),
        .wb_csr_we_i(wb_csr_we_o),

        .dhnf_harzard_sel1_o(dhnf_harzard_sel1_o),
        .dhnf_harzard_sel2_o(dhnf_harzard_sel2_o),

        .dhnf_forward_data1_o(dhnf_forward_data1_o),
        .dhnf_forward_data2_o(dhnf_forward_data2_o),

        .dhnf_harzard_csrsel_o(dhnf_harzard_csrsel_o),
        .dhnf_forward_csr_o(dhnf_forward_csr_o)
    );

    regs regs_ins(
        .clk(clk),
        .rst_n(rst_n),

        .id_reg1_raddr_i(id_reg1_raddr_o),
        .id_reg2_raddr_i(id_reg2_raddr_o),  

        .regs_reg1_rdata_o(regs_reg1_rdata_o),
        .regs_reg2_rdata_o(regs_reg2_rdata_o), 

        .wb_reg_wdata_i(wb_reg_wdata_o),
        .wb_reg_waddr_i(wb_reg_waddr_o),
        .wb_reg_we_i(wb_reg_we_o)
    );

    Icache Icache_ins(
        .clk(clk),
        .rst_n(rst_n),

        .if_pc_i(if_pc_o), 
        .if_req_Icache_i(if_req_Icache_o),

        .Icache_inst_o(Icache_inst_o),

        .Icache_ready_o(Icache_ready_o),
        .Icache_hit_o(Icache_hit_o),

        .fc_jump_flag_Icache_i(fc_jump_flag_Icache_o),
        .fc_stall_Icache_i(fc_stall_Icache_o),

        .Icache_addr_o(Icache_addr_o),
        .Icache_valid_req_o(Icache_valid_req_o),

        .bc_Icache_ready_i(bc_Icache_ready_o),
        .bc_Icache_data_i(bc_Icache_data_o)
    );

    Dcache Dcache_ins(
        .clk(clk),
        .rst_n(rst_n),

        .ex_mem_rw_i(ex_mem_rw_o), 
        .ex_req_Dcache_i(ex_req_Dcache_o), 

        .ex_mem_addr_i(ex_mem_addr_o), 
        .ex_mem_wrwidth_i(ex_mem_wrwidth_o), 
        .ex_mem_wr_data_i(ex_mem_wr_data_o),

        .Dcache_data_o(Dcache_data_o), 

        .Dcache_ready_o(Dcache_ready_o),
        .Dcache_hit_o(Dcache_hit_o),

        .Dcache_rd_req_o(Dcache_rd_req_o), 
        .Dcache_rd_addr_o(Dcache_rd_addr_o),

        .Dcache_wb_req_o(Dcache_wb_req_o),  
        .Dcache_wb_addr_o(Dcache_wb_addr_o),
        .Dcache_wb_data_o(Dcache_wb_data_o),

        .bc_Dcache_data_i(bc_Dcache_data_o),
        .bc_Dcache_ready_i(bc_Dcache_ready_o)
    );

    Flow_Ctrl fc_ins(
        .clk(clk),
        .rst_n(rst_n),

        .id_jump_flag_i(id_jump_flag_o),
        .id_jump_pc_i(id_jump_pc_o),

        .id_load_use_flag_i(id_load_use_flag_o),

        .ex_branch_flag_i(ex_branch_flag_o),
        .ex_branch_pc_i(ex_branch_pc_o),

        .if_req_Icache_i(if_req_Icache_o),
        .ex_req_Dcache_i(ex_req_Dcache_o),
        .ex_req_bus_i(ex_req_bus_o),

        .Icache_hit_i(Icache_hit_o),
        .Dcache_hit_i(Dcache_hit_o),

        .bc_Icache_ready_i(bc_Icache_ready_o),
        .bc_Dcache_ready_i(bc_Dcache_ready_o),
        .bc_bus_ready_i(bc_bus_ready_o),
        .core_WAIT_i(core_WAIT_bus_o),


        .fc_flush_ifid_o(fc_flush_ifid_o),
        .fc_flush_idex_o(fc_flush_idex_o),
        .fc_flush_exmem_o(fc_flush_exmem_o),
        .fc_flush_memwb_o(fc_flush_memwb_o),
        .fc_flush_id_o(fc_flush_id_o),
        .fc_flush_ex_o(fc_flush_ex_o),
        .fc_flush_mem_o(fc_flush_mem_o),

        .fc_jump_pc_if_o(fc_jump_pc_if_o),
        .fc_jump_flag_if_o(fc_jump_flag_if_o),

        .fc_jump_flag_Icache_o(fc_jump_flag_Icache_o),

        .fc_stall_if_o(fc_stall_if_o),
        .fc_stall_id_o(fc_stall_id_o),
        .fc_stall_ex_o(fc_stall_ex_o),
        .fc_stall_mem_o(fc_stall_mem_o),
        .fc_stall_wb_o(fc_stall_wb_o),
        .fc_stall_Icache_o(fc_stall_Icache_o),

        .fc_stall_ifid_o(fc_stall_ifid_o),
        .fc_stall_idex_o(fc_stall_idex_o),
        .fc_stall_exmem_o(fc_stall_exmem_o),
        .fc_stall_memwb_o(fc_stall_memwb_o)
    );


        csr_regs csr_regs_ins(
            .clk(clk),
            .rst_n(rst_n),
            .id_csr_raddr_i(id_csr_raddr_o),
            .csr_regs_rdata_o(csr_regs_rdata_o),
            .wb_csr_wdata_i(wb_csr_wdata_o),
            .wb_csr_waddr_i(wb_csr_waddr_o),
            .wb_csr_we_i(wb_csr_we_o)
        );


        bus_controller bc_ins(

        .clk(clk),
        .rst_n(rst_n),

        .Icache_addr_i(Icache_addr_o),
        .Icache_valid_req_i(Icache_valid_req_o),

        .bc_Icache_ready_o(bc_Icache_ready_o),
        .bc_Icache_data_o(bc_Icache_data_o),

        .Dcache_rd_req_i(Dcache_rd_req_o),
        .Dcache_rd_addr_i(Dcache_rd_addr_o),
        .Dcache_wb_req_i(Dcache_wb_req_o),
        .Dcache_wb_addr_i(Dcache_wb_addr_o),
        .Dcache_wb_data_i(Dcache_wb_data_o),

        .ex_req_bus_i(ex_req_bus_o),
        .ex_mem_rw_i(ex_mem_rw_o),
        .ex_mem_addr_i(ex_mem_addr_o),
        .ex_mem_data_i(ex_mem_wr_data_o),

        .bc_bus_ready_o(bc_bus_ready_o),
        .bc_bus_data_o(bc_bus_data_o),



        .bc_Dcache_ready_o(bc_Dcache_ready_o),
        .bc_Dcache_data_o(bc_Dcache_data_o),

        .bc_valid_req_o(bc_valid_req_o),
        .bc_rw_o(bc_rw_o),
        .bc_addr_o(bc_addr_o),
        .bc_data_o(bc_data_o), 

        .axi_data_i(axi_data_i),  //to axi controller
        .axi_rd_over_i(axi_rd_over_i),
        .axi_wr_over_i(axi_wr_over_i),

        .core_WAIT_i(core_WAIT_i),
        .core_WAIT_bus_o(core_WAIT_bus_o), //stall Icache,Dcache        

        .fc_jump_flag_Icache_i(fc_jump_flag_Icache_o)
    );




endmodule