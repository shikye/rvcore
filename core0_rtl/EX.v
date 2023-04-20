`include "define.v"
module EX (
    input   wire                    clk,
    input   wire                    rst_n,

    //from id_ex_reg
    input   wire            [31:0]  idex_op_a_i,
    input   wire            [31:0]  idex_op_b_i,
    input   wire            [4:0]   idex_reg_waddr_i,
    input   wire                    idex_reg_we_i,

    input   wire            [4:0]   idex_ALUctrl_i,

    input   wire                    idex_btype_flag_i,
    input   wire            [31:0]  idex_btype_jump_pc_i,

    input   wire                    idex_mtype_i,          
    input   wire                    idex_mem_rw_i,          
    input   wire            [1:0]   idex_mem_width_i,      
    input   wire            [31:0]  idex_mem_wr_data_i,   
    input   wire                    idex_mem_rdtype_i,  

    input   wire                    idex_csr_we_i,
    input   wire            [11:0]  idex_csr_waddr_i,
    input   wire            [31:0]  idex_csr_rdata_i,

    //to ex_mem_reg
    output  wire            [31:0]  ex_reg_wdata_o,
    output  wire            [4:0]   ex_reg_waddr_o,
    output  wire                    ex_reg_we_o,

    output  wire            [31:0]  ex_csr_wdata_o,
    output  wire            [11:0]  ex_csr_waddr_o,
    output  wire                    ex_csr_we_o,

    output  wire                    ex_mtype_o,  
    output  wire                    ex_mem_rw_o,                 //and Dcache
    output  wire            [1:0]   ex_mem_width_o,
    output  wire                    ex_mem_rdtype_o,     //0-signed 1-unsigned
    //output  wire            [31:0]  ex_mem_addr_o,


    //to Dcache
    output  wire                    ex_req_Dcache_o,  //to Dcache and fc
    
    output  wire            [31:0]  ex_mem_addr_o,              //also to exmem
    output  wire            [1:0]   ex_mem_wrwidth_o,
    output  wire            [31:0]  ex_mem_wr_data_o,


    //to fc
    output  wire                    ex_branch_flag_o,
    output  wire            [31:0]  ex_branch_pc_o,

    //from fc
    input   wire                    fc_stall_ex_i,

    //to fc and bus_controller
    output  wire                    ex_req_bus_o   //由于一次访存指令只会是bus类型或者Dcache类型，所以让bus行为取代Dcache行为
                                                   //外部直接视为是Dcache类型

);


reg             [31:0]  ex_op_c_o;

//mtype
assign ex_mtype_o = idex_mtype_i;
assign ex_mem_rw_o = idex_mem_rw_i;
assign ex_mem_width_o = idex_mem_width_i;


//--------to Dcache
assign ex_mem_rw_o = idex_mem_rw_i;
assign ex_mem_addr_o = ex_op_c_o;
assign ex_mem_wrwidth_o = idex_mem_width_i;
assign ex_mem_wr_data_o = idex_mem_wr_data_i;
assign ex_mem_rdtype_o = idex_mem_rdtype_i;


//找上升沿  flag信号应该使用上升沿判断 牢记多个控制信号可能会导致混乱
reg req_Dcache_buffer, req_bus_buffer;

always@(posedge clk)begin
    if(rst_n == 1'b0)begin
        req_Dcache_buffer <= 1'b0;
        req_bus_buffer <= 1'b0;
    end
    else begin
        req_Dcache_buffer <= req_Dcache;
        req_bus_buffer <= req_bus;
    end

end


assign req_Dcache = (idex_mtype_i && (ex_mem_addr_o < 32'h2000_0000) )? 1'b1 : 1'b0;
assign req_bus = (idex_mtype_i && (ex_mem_addr_o >= 32'h2000_0000) )? 1'b1 : 1'b0;

assign ex_req_Dcache_o = (idex_mtype_i && (ex_mem_addr_o < 32'h2000_0000) )? 1'b1 : 1'b0;
assign ex_req_bus_o = ~req_bus_buffer && req_bus;





    wire [31:0] op_a = idex_op_a_i;
    wire [31:0] op_b = idex_op_b_i;

    always @(*) begin
        case(idex_ALUctrl_i)
            `ADD:   ex_op_c_o = op_a + op_b;
            `SUB:   ex_op_c_o = op_a - op_b;
            `EQU:   ex_op_c_o = ((op_a ^ op_b) == 32'h0) ? 32'b1 : 32'b0;
            `NEQ:   ex_op_c_o = ((op_a ^ op_b) == 32'h0) ? 32'b0 : 32'b1;
            `SLT:   ex_op_c_o = ($signed(op_a) < $signed(op_b)) ? 32'b1 : 32'b0;
            `SGE:   ex_op_c_o = ($signed(op_a) < $signed(op_b)) ? 32'b0 : 32'b1;
            `SLTU:  ex_op_c_o = ($unsigned(op_a) < $unsigned(op_b)) ? 32'b1 : 32'b0;
            `SGEU:  ex_op_c_o = ($unsigned(op_a) < $unsigned(op_b)) ? 32'b0 : 32'b1;
            `XOR:   ex_op_c_o = op_a ^ op_b;
            `OR:    ex_op_c_o = op_a | op_b;
            `SLL:   ex_op_c_o = op_a << op_b[4:0];
            `SRL:   ex_op_c_o = op_a >> op_b[4:0];
            `SRA:   ex_op_c_o = ($signed(op_a)) >>> op_b[4:0];   
            `AND:   ex_op_c_o = op_a & op_b;       
            `NAND:  ex_op_c_o = op_a & op_b;       
            `NO_OP: ex_op_c_o = 32'h0;
            default:ex_op_c_o = 32'h0;
        endcase
    end

    

    assign ex_branch_flag_o = ex_op_c_o && idex_btype_flag_i; 
    //when op == 1 && is a branch inst
    assign ex_branch_pc_o = idex_btype_jump_pc_i;


    //-------for csr_inst
    assign ex_reg_wdata_o = ex_csr_we_o ? idex_csr_rdata_i : ex_op_c_o;
    assign ex_reg_waddr_o = idex_reg_waddr_i;
    assign ex_reg_we_o = idex_reg_we_i;

    assign ex_csr_wdata_o = ex_op_c_o;
    assign ex_csr_waddr_o = idex_csr_waddr_i;
    assign ex_csr_we_o = idex_csr_we_i;

    

endmodule