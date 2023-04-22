`include "define.v"
module clint(
    input   wire                    clk,
    input   wire                    rst_n,

    //from timer
    input   wire                    timer_int_i,

    //from id
    input   wire            [31:0]  id_inst_i,
    input   wire            [31:0]  id_pc_i,

    input   wire                    id_jump_flag_i,
    input   wire            [31:0]  id_jump_pc_i,

    //from ex
    input   wire                    ex_branch_flag_i,
    input   wire            [31:0]  ex_branch_pc_i,

    //from csr_regs
    input   wire            [31:0]  mstatus_i,
    input   wire            [31:0]  mtvec_i,
    input   wire            [31:0]  mepc_i,
    

    //to csr_regs
    output  reg             [11:0]  cl_csr_waddr_o,
    output  reg             [31:0]  cl_csr_wdata_o,
    output  reg                     cl_csr_we_o,
    //to if
    output  reg                     cl_int_o,
    output  reg             [31:0]  cl_addr_o,

    //from fc
    input   wire                    inst_forward_over,
    //to fc
    output  wire                    cl_stall_o
);

    reg [1:0]   Int_state;

    localparam S_INT_IDLE = 0;
    localparam S_INT_ASYN = 1; //处理异步中断
    localparam S_INT_SYN = 2; //处理同步中断
    localparam S_INT_RET = 3; //中断返回


    reg [2:0]   Csr_state;  //依次写csr寄存器

    localparam S_CSR_IDLE = 0;
    localparam S_CSR_MEPC = 1;
    localparam S_CSR_MCAUSE = 2;
    localparam S_CSR_MSTATUS = 3;
    localparam S_CSR_MRET = 4;
    localparam S_CSR_WAIT = 5;



    reg [1:0] int_type; //1-SYN,2-ASYN,3-MRET


    always@(*)begin      //需要立即给出中断信号，故不使用时序逻辑
        if(rst_n == 1'b0)
            Int_state = S_INT_IDLE;
        else begin
            if((id_inst_i == `INST_ECALL || id_inst_i == `INST_EBREAK))
                Int_state = S_INT_SYN;
            else if(mstatus_i[3] && timer_int_i)  //全局中断
                Int_state = S_INT_ASYN;
            else if(id_inst_i == `INST_MRET)
                Int_state = S_INT_RET;
            else 
                Int_state = S_INT_IDLE;
        end
    end

    always@(posedge clk)begin
        if(rst_n == 1'b0)
            int_type <= 2'd0;
        else begin
            if(inst_forward_over == 1'b0)begin
                if(Int_state == S_INT_SYN)
                    int_type <= 2'd1;
                else if(Int_state == S_INT_ASYN)
                    int_type <= 2'd2;
                else if(Int_state == S_INT_RET)
                    int_type <= 2'd3;
                else 
                    int_type <= 2'd0;
            end
            else 
                int_type <= 2'd0;
        end
    end


    reg [31:0]  int_cause;
    reg [31:0]  int_addr;

    //写csr的状态转换  ，与写csr的always块分开更清晰
    always@(posedge clk) begin
        if(rst_n == 1'b0)begin
            Csr_state <= S_CSR_IDLE;
            int_cause <= 32'd0;
            int_addr <= 32'd0;
        end
        else begin
            case(Csr_state)
                S_CSR_IDLE:begin
                    if(Int_state == S_INT_ASYN)begin      //异步中断
                        int_cause <= 32'h8000_0007; //m模式下的时钟中断
                        Csr_state <= S_CSR_MEPC;

                        if(id_jump_flag_i)
                            int_addr <= id_jump_pc_i;
                        else if(ex_branch_flag_i)
                            int_addr <= ex_branch_pc_i;    
                        else 
                            int_addr <= id_inst_i;

                    end
                    else if(Int_state == S_INT_SYN)begin      //同步中断
                        Csr_state <= S_CSR_MEPC;

                        if(ex_branch_flag_i) //同步中断，id中不会是jump指令
                            int_addr <= ex_branch_pc_i;
                        else 
                            int_addr <= id_inst_i;
                        
                        case(id_inst_i)
                            `INST_ECALL:int_cause <= 32'h8;
                            `INST_EBREAK:int_cause <= 32'h3;
                            default:;
                        endcase
                    
                    end
                    else if(Int_state == S_INT_RET)begin   //中断返回
                        Csr_state <= S_CSR_MRET;
                    end
                end


                S_CSR_MEPC: Csr_state <= S_CSR_MCAUSE;

                S_CSR_MCAUSE: Csr_state <= S_CSR_MSTATUS;

                S_CSR_MSTATUS:begin
                    if(inst_forward_over == 1'b1)
                        Csr_state <= S_CSR_IDLE;
                    else 
                        Csr_state <= S_CSR_WAIT;
                end
        
                S_CSR_MRET:begin
                    if(inst_forward_over == 1'b1)
                        Csr_state <= S_CSR_IDLE;
                    else 
                        Csr_state <= S_CSR_WAIT;
                end

                S_CSR_WAIT:begin
                    if(inst_forward_over == 1'b1)
                        Csr_state <= S_CSR_IDLE;
                    else 
                        Csr_state <= S_CSR_WAIT;
                end

                default:Csr_state <= S_CSR_IDLE;
        
            endcase
        end
    end



    //在不同csr_state下，按序写csr寄存器
    always@(posedge clk)begin
        if(rst_n == 1'b0)begin
            cl_csr_waddr_o <= 12'd0;
            cl_csr_wdata_o <= 32'd0;
            cl_csr_we_o <= 1'b0;
        end
        else begin
            case(Csr_state)
                S_CSR_MEPC:begin
                    cl_csr_waddr_o <= `MEPC;
                    cl_csr_wdata_o <= int_addr;
                    cl_csr_we_o <= 1'b1;
                end
                S_CSR_MCAUSE:begin
                    cl_csr_waddr_o <= `MCAUSE;
                    cl_csr_wdata_o <= int_cause;
                    cl_csr_we_o <= 1'b1;
                end
                S_CSR_MSTATUS:begin
                    cl_csr_waddr_o <= `MSTATUS;
                    cl_csr_wdata_o <= {mstatus_i[31:8],mstatus_i[3],mstatus_i[6:4],1'b0,mstatus_i[2:0]}; //关闭全局中断
                    cl_csr_we_o <= 1'b1;                                                                 //将MIE保存到MPIE
                end
                S_CSR_MRET:begin
                    cl_csr_waddr_o <= `MSTATUS;
                    cl_csr_wdata_o <= {mstatus_i[31:4],mstatus_i[7],mstatus_i[2:0]};  //从MPIE恢复
                    cl_csr_we_o <= 1'b1;
                end
                S_CSR_WAIT:begin
                    cl_csr_waddr_o <= 12'd0;
                    cl_csr_wdata_o <= 32'd0;  //从MPIE恢复
                    cl_csr_we_o <= 1'b0;
                
                end
                default:begin
                    cl_csr_waddr_o <= 12'd0;
                    cl_csr_wdata_o <= 32'd0;
                    cl_csr_we_o <= 1'b0;
                end
        
        
            endcase
        end
    end



    //执行流控制
    assign cl_stall_o = ((Int_state != S_INT_IDLE) | (Csr_state != S_CSR_IDLE)) ? 1'b1 : 1'b0;


    always@(posedge clk)begin
        if(rst_n == 1'b0)begin
            cl_int_o <= 1'b0;
            cl_addr_o <= 32'd0;
        end
        else begin
            case(Csr_state)
                S_CSR_MSTATUS:begin
                    cl_int_o <= 1'b1;
                    cl_addr_o <= mtvec_i;
                end
                S_CSR_MRET:begin
                    cl_int_o <= 1'b1;
                    cl_addr_o <= mepc_i;
                end
                S_CSR_WAIT:begin
                    cl_int_o <= 1'b0;
                    cl_addr_o <= 32'd0;
                end
                default:begin
                    cl_int_o <= 1'b0;
                    cl_addr_o <= 32'd0;
                end
        
            endcase
        end
    
    end






endmodule