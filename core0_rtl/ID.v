 `include "define.v"
module ID (
    input   wire                    clk,
    input   wire                    rst_n,

    //from if_id_reg
    input   wire            [31:0]  ifid_pc_i,

    //from regs
    input   wire            [31:0]  regs_reg1_rdata_i,
    input   wire            [31:0]  regs_reg2_rdata_i,

    //to regs and dhnf
    output  wire            [4:0]   id_reg1_raddr_o,
    output  wire            [4:0]   id_reg2_raddr_o,

    //to id_ex_reg
    output  wire            [31:0]  id_op_a_o,
    output  wire            [31:0]  id_op_b_o,

    output  wire            [4:0]   id_reg_waddr_o,
    output  wire                    id_reg_we_o,

    output  wire            [4:0]   id_ALUctrl_o,

    output  wire                    id_btype_flag_o,
    output  wire            [31:0]  id_btype_jump_pc_o,

//----------for load/store inst-------
    output  wire                    id_mtype_o,  //load/store type
    output  wire                    id_mem_rw_o,  //0--wr, 1--rd
    output  wire            [1:0]   id_mem_width_o, //1--byte, 2--hw, 3--word
    output  wire            [31:0]  id_mem_wr_data_o,
    output  wire                    id_mem_rdtype_o,   //signed --0, unsigned --1

 //-----------------------------------

    //from dhnf
    input   wire                    dhnf_harzard_sel1_i,
    input   wire                    dhnf_harzard_sel2_i,
    input   wire            [31:0]  dhnf_forward_data1_i,
    input   wire            [31:0]  dhnf_forward_data2_i,
    //to dhnf
    output  wire                    id_reg1_RE_o,
    output  wire                    id_reg2_RE_o,


    //from Icache
    input   wire                    Icache_ready_i,         //当ready时，就接收
    input   wire            [31:0]  Icache_inst_i,          //如果此时stall，那么存入buffer

    //from fc
    input   wire                    fc_flush_id_i,
    input   wire                    fc_stall_id_i,

    //to fc
    output  wire                    id_jump_flag_o,
    output  wire            [31:0]  id_jump_pc_o,

    output  wire                    id_load_use_flag_o,

    //to csr_regs and dhnf
    output  wire            [11:0]  id_csr_raddr_o,
    output  wire                    id_csr_RE_o,

    //from csr_regs
    input   wire            [31:0]  csr_regs_rdata_i,

    //from dhnf
    input   wire                    dhnf_harzard_csrsel_i,
    input   wire            [31:0]  dhnf_forward_csr_i,

    //to id_ex_reg
    output  wire                    id_csr_we_o,
    output  wire            [11:0]  id_csr_waddr_o,
    output  wire            [31:0]  id_csr_rdata_o,

    
    //from clint
    input   wire                    cl_stall_i,

    //to clint
    output  wire            [31:0]  id_inst_o,
    output  wire            [31:0]  id_pc_o,

    output  wire                    id_ins_flag //用于判断流水线寄存器中是否存在指令， idex、exmem、memwb

    
);

assign id_ins_flag = (inst != 32'd0) && (inst != 32'h0000_0013);

assign id_inst_o = inst;
assign id_pc_o = ifid_pc_i;


    wire [31:0] inst;

//-----------decode
    wire [6:0]  opcode = inst[6:0];
    wire [4:0]  rd     = inst[11:7];
    wire [2:0]  func3  = inst[14:12];
    wire [4:0]  rs1    = inst[19:15];
    wire [4:0]  rs2    = inst[24:20];
    wire [6:0]  func7  = inst[31:25];
    wire [5:0]  shamt  = inst[25:20];

    wire [11:0] csr_addr = inst[31:20];
//--------------------------------------

    assign id_csr_raddr_o = csr_addr;
    assign id_csr_waddr_o = csr_addr;


//-----------------------------------------seen as part of if_id_reg
//------for flush btype or jump_inst
    reg flush_flag;
    
    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
            flush_flag <= 1'b0;
        else if(fc_flush_id_i)
            flush_flag <= 1'b1;
        else
            flush_flag <= 1'b0;
    end




//-----for other keep and Icache_inst need to store------
    reg [31:0]  Inst_Buffer[0:1];
    reg         Icache_in_Buffer;
    reg [1:0]   Buffer_number;

    reg [31:0]  Buffer_to_id;


    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            Inst_Buffer[0] <= 32'h0;
            Inst_Buffer[1] <= 32'h0;
            Buffer_to_id <= 32'd0;
            Buffer_number <= 2'd0;
            Icache_in_Buffer <= 1'b0;
        end

        //流水线暂停，但此时Icache给出了有效数据，ID需要保存，而不是直接使用
        else if(fc_stall_id_i == 1'b1 && Icache_ready_i == 1'b1)begin   
            
            Icache_in_Buffer <= 1'b1;

            if(Buffer_number == 2'd0)begin
                Buffer_number <= 2'd1;
                Inst_Buffer[0] <= Icache_inst_i;
                Buffer_to_id <= Icache_inst_i;
            end
            else if(Buffer_number == 2'd1)begin
                Buffer_number <= 2'd2;
                Inst_Buffer[1] <= Icache_inst_i;
            end
        end

        else if(fc_stall_id_i == 1'b1) begin  //keep
            Icache_in_Buffer <= Icache_in_Buffer;
            Buffer_number <= Buffer_number;
            Inst_Buffer[0] <= Inst_Buffer[0];
            Inst_Buffer[1] <= Inst_Buffer[1];   
        end

        else if(fc_flush_id_i == 1'b1)begin
            Icache_in_Buffer <= 1'b0;
            Inst_Buffer[0] <= 32'd0;
            Inst_Buffer[1] <= 32'd0;   
            Buffer_number <= 2'd0;
        end

        else if(recover_flag == 1'b1)begin
            Icache_in_Buffer <= 1'd1;
            Buffer_to_id <= Icache_inst_i;
        
        end

        else begin
            
            Inst_Buffer[0] <= Icache_inst_i;
            
            if(Icache_in_Buffer == 1'b1) begin

                if(Buffer_number == 2'd2)begin
                    Buffer_to_id <= Inst_Buffer[1];
                    Buffer_number <= 2'd1;
                end
                else if(Buffer_number == 2'd1)begin
                    Buffer_to_id <= Icache_inst_i;
                    Buffer_number <= 2'd0;
                    Icache_in_Buffer <= 1'd0;
                end
                else begin
                    
                    Buffer_to_id <= 32'd0;
                    Buffer_number <= 2'd0;
                    Icache_in_Buffer <= 1'd0;
                end
                

            end
        end

    end

//--------------------for load_use
    reg [31:0] inst_load_use;   //store the lb inst
    reg [4:0]  reg_load_use;

    reg        load_use_flag;
    reg        recover_flag;

    reg [31:0]  recover_inst;

    assign id_load_use_flag_o = load_use_flag;

   
    always @(*) begin  
        if(( Icache_inst_i[19:15] == reg_load_use || Icache_inst_i[24:20] == reg_load_use ) && reg_load_use != 5'd0)
            load_use_flag = 1'b1;
        else 
            load_use_flag = 1'b0;
    end

    always@(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0) begin
            recover_flag <= 1'b0;
            recover_inst <= 32'd0;
        end
        else if(load_use_flag == 1'b1) begin
            recover_flag <= 1'b1;
            recover_inst <= Icache_inst_i;
        end
        else 
            recover_flag <= 1'b0;
    end
    
    always@(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0) begin
            inst_load_use <= 32'h0;
            reg_load_use <= 5'd0;
        end
        else begin
            if(Icache_inst_i == `Itype_L) begin
                inst_load_use <= inst;
                reg_load_use <= rd;
            end
            else begin
                inst_load_use <= 32'h0;
                reg_load_use <= 5'd0;
            end
        end
    end

//-----------------------------------------
    assign inst = load_use_flag ? 32'd0 : recover_flag ? recover_inst :  flush_flag | cl_stall_buffer ? 32'h0 :  Icache_ready_i ? Icache_inst_i : int_type ? 32'd0 : Icache_in_Buffer ? Buffer_to_id :  32'h0;  //顺序重要


    reg int_type;
    always @(posedge clk) begin
        if(rst_n == 1'b0)
            int_type <= 1'b0;
        else begin
            if(inst == `INST_EBREAK || inst == `INST_ECALL || inst == `INST_MRET)
                int_type <= 1'b1;
            else if(inst != 32'd0)
                int_type <= 1'b0;
        end
        
    end

    reg cl_stall_buffer;
    always @(posedge clk) begin
        if(rst_n == 1'b0)
            cl_stall_buffer <= 1'b0;
        else begin
            cl_stall_buffer <= cl_stall_i;
        end
        
    end



//---------------control unit

    wire [4:0] cu_ALUctrl_o;
    wire       cu_reg_we_o;
    wire       cu_op_b_sel_o;

    wire       cu_reg1_RE_o;
    wire       cu_reg2_RE_o;

    wire       cu_mtype_o;
    wire       cu_mem_rw_o;
    wire [1:0] cu_mem_width_o;
    wire       cu_mem_rdtype_o;

    wire       cu_csr_RE_o;
    wire       cu_csr_we_o;
    wire       cu_csr_sel_o;


    cu cu_ins(
        .clk(clk),
        .rst_n(rst_n),
        .id_opcode_i(opcode),
        .id_func3_i(func3),
        .id_func7_i(func7),

        .cu_ALUctrl_o(cu_ALUctrl_o),
        .cu_reg_we_o(cu_reg_we_o),
        .cu_op_b_sel_o(cu_op_b_sel_o),

        .cu_mtype_o(cu_mtype_o),
        .cu_mem_rw_o(cu_mem_rw_o),
        .cu_mem_width_o(cu_mem_width_o),
        .cu_mem_rdtype_o(cu_mem_rdtype_o),

        .cu_reg1_RE_o(cu_reg1_RE_o),
        .cu_reg2_RE_o(cu_reg2_RE_o),

        .cu_csr_RE_o(cu_csr_RE_o),
        .cu_csr_we_o(cu_csr_we_o),
        .cu_csr_sel_o(cu_csr_sel_o)
    );

    assign id_ALUctrl_o = cu_ALUctrl_o;
    assign id_reg_we_o = cu_reg_we_o;
    assign id_mtype_o = cu_mtype_o;
    assign id_mem_rw_o = cu_mem_rw_o;
    assign id_mem_width_o = cu_mem_width_o;
    assign id_mem_rdtype_o = cu_mem_rdtype_o;
    assign id_reg1_RE_o = cu_reg1_RE_o;
    assign id_reg2_RE_o = cu_reg2_RE_o;

    assign id_csr_RE_o = cu_csr_RE_o;
    assign id_csr_we_o = cu_csr_we_o;

//-----------------------------


//----------eximm
wire [31:0] inst_o = inst;
wire [31:0] eximm_eximm_o;


eximm eximm_ins(
    .id_inst_i(inst_o),
    .eximm_eximm_o(eximm_eximm_o)
);
    

//----------------------from regs
    wire [31:0] rd1_after_hazard = dhnf_harzard_sel1_i ? dhnf_forward_data1_i : regs_reg1_rdata_i;
    wire [31:0] rd2_after_hazard = dhnf_harzard_sel2_i ? dhnf_forward_data2_i : regs_reg2_rdata_i;

    wire [31:0] csr_after_hazard = dhnf_harzard_csrsel_i ? dhnf_forward_csr_i : csr_regs_rdata_i;


//---------other output signals
    assign id_reg1_raddr_o = rs1;
    assign id_reg2_raddr_o = rs2;
    assign id_reg_waddr_o  = rd;

    assign id_csr_rdata_o = csr_after_hazard;


    assign id_op_a_o = (opcode == `Utype_L) ? 32'h0 : 
                        (opcode == `Utype_A) ? ifid_pc_i :
                        (opcode == `Jtype_J || opcode == `Itype_J) ? ifid_pc_i :
                        ( (opcode == `Itype_C && func3 == `I_CSRRS) || (opcode == `Itype_C && func3 == `I_CSRRSI) 
                        || (opcode == `Itype_C && func3 == `I_CSRRC) || (opcode == `Itype_C && func3 == `I_CSRRCI)   
                        ) ? csr_after_hazard :
                        rd1_after_hazard;         //most from regs

    assign id_op_b_o = (opcode == `Jtype_J || opcode == `Itype_J) ? 32'd4 :
                        (opcode == `Itype_A && (func3 == `I_SLLI || func3 == `I_SRLI_SRAI) ) ? shamt :
                        ( (opcode == `Itype_C && func3 == `I_CSRRS) || (opcode == `Itype_C && func3 == `I_CSRRC)   
                        ) ? rd1_after_hazard :
                        (opcode == `Itype_C) ? eximm_eximm_o :
                        cu_op_b_sel_o ? eximm_eximm_o :
                        rd2_after_hazard;           //most from regs or eximm

    
    assign id_mem_wr_data_o = rd2_after_hazard; //Stype

  
    assign id_jump_flag_o = (opcode == `Jtype_J || opcode == `Itype_J) ? 1'b1 : 1'b0;   //jal and jalr
    assign id_jump_pc_o   = (opcode == `Jtype_J ) ? (ifid_pc_i + eximm_eximm_o) : (rd1_after_hazard + eximm_eximm_o);

    assign id_btype_flag_o = (opcode == `Btype) ? 1'b1 : 1'b0;
    assign id_btype_jump_pc_o = ifid_pc_i + eximm_eximm_o;  //only btype


endmodule