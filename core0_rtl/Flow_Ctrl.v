module Flow_Ctrl(                  //Flush, Stall, Jump

    input   wire                    clk,
    input   wire                    rst_n,
    

//-------------------------jump
    //from id
    input   wire                    id_jump_flag_i,
    input   wire            [31:0]  id_jump_pc_i,

    input   wire                    id_load_use_flag_i,  //load_use
    //from ex
    input   wire                    ex_branch_flag_i,
    input   wire            [31:0]  ex_branch_pc_i,


//------------------------------- 
    //from if
    input   wire                    if_req_Icache_i,

    //from ex
    input   wire                    ex_req_Dcache_i,

    input   wire                    ex_req_bus_i,

    //from Icache
    input   wire                    Icache_hit_i,

    //from Dcache
    input   wire                    Dcache_hit_i,

    //from bus_controller
    input   wire                    bc_Icache_ready_i,
    input   wire                    bc_Dcache_ready_i,
    input   wire                    bc_bus_ready_i,
    input   wire                    core_WAIT_i,

    //from clint
    input   wire                    cl_stall_i,




    //------------------执行完成
    input   wire                    idex_ins_flag,
    input   wire                    exmem_ins_flag,
    input   wire                    memwb_ins_flag,

    

//-------Flush: Jal,Jalr,Btype ------- to if_id_reg, id_ex_reg, 
//pc, Icache, id_inst(to clean)
    
    
    output  reg                     fc_flush_ifid_o,
    output  reg                     fc_flush_idex_o,
    output  reg                     fc_flush_exmem_o,
    output  reg                     fc_flush_memwb_o,
    output  reg                     fc_flush_id_o,
    output  reg                     fc_flush_ex_o,
    output  reg                     fc_flush_mem_o,


    output  wire            [31:0]  fc_jump_pc_if_o,
    output  wire                    fc_jump_flag_if_o,

    output  wire                    fc_jump_flag_Icache_o,



//-------Stall to pc, id_inst, if_id_reg,
//id_ex_reg, ex_mem_reg, mem_wb_reg

    output  reg                     fc_stall_if_o,
    output  reg                     fc_stall_id_o,
    output  reg                     fc_stall_ex_o,
    output  reg                     fc_stall_mem_o,
    output  reg                     fc_stall_wb_o,
    output  reg                     fc_stall_Icache_o,

    output  reg                     fc_stall_ifid_o,
    output  reg                     fc_stall_idex_o,
    output  reg                     fc_stall_exmem_o,
    output  reg                     fc_stall_memwb_o,


    //to clint
    output  wire                     inst_forward_over
    
);

assign inst_forward_over = (!idex_ins_flag) & (!exmem_ins_flag) & (!memwb_ins_flag);


assign fc_jump_flag_Icache_o = fc_jump_flag_if_o;   //Icache jump



//----------------from rom  -- for stall
reg Icache_stall_flag;

    always@(*) begin
        if(rst_n == 1'b0) begin
            Icache_stall_flag = 1'b0;
        end

        else if( (bc_Icache_ready_i == 1'b1) || (fc_jump_flag_if_o == 1'b1 && Icache_hit_i == 1'b1) ||              //最后一个分支是重点！！！！！！！
            (if_req_Icache_i == 1'b1 && Icache_hit_i == 1'b1) ) begin
            Icache_stall_flag = 1'b0;
        end

        else if(if_req_Icache_i == 1'b1 && Icache_hit_i == 1'b0) begin // hit can be get instantly    ---------------------------------！！！！！！！no delay， so no need to back
            Icache_stall_flag = 1'b1;                                   //notice: has a first and second sequence in a time
        end                                                     //priority is higher than next branch


        
        
        else 
            Icache_stall_flag = Icache_stall_flag;
    end


//-------------from Dcache   --for stall
reg Dcache_stall_flag;


always@(*) begin
    if(rst_n == 1'b0)
        Dcache_stall_flag = 1'b0;
    else if( (ex_req_Dcache_i == 1'b1 && Dcache_hit_i == 1'b0)  ||  ex_req_bus_i)
        Dcache_stall_flag = 1'b1;
    else if( bc_bus_ready_i || bc_Dcache_ready_i == 1'b1 || (ex_req_Dcache_i == 1'b1 && Dcache_hit_i == 1'b1) )  // one open condition
        Dcache_stall_flag = 1'b0;
    
    
end


//--------------for stall
always@(*)begin
    fc_stall_if_o = 1'b0;
    fc_stall_id_o = 1'b0;
    fc_stall_ex_o = 1'b0;
    fc_stall_mem_o = 1'b0;
    fc_stall_wb_o = 1'b0;
    fc_stall_Icache_o = 1'b0;

    fc_stall_ifid_o = 1'b0;
    fc_stall_idex_o = 1'b0;
    fc_stall_exmem_o = 1'b0;
    fc_stall_memwb_o = 1'b0;

    if(core_WAIT_i)begin
        fc_stall_if_o = 1'b1;
        fc_stall_id_o = 1'b1;
        fc_stall_ex_o = 1'b1;
        fc_stall_mem_o = 1'b1;
        fc_stall_wb_o = 1'b1;
        fc_stall_Icache_o = 1'b1;

        fc_stall_ifid_o = 1'b1;
        fc_stall_idex_o = 1'b1;
        fc_stall_exmem_o = 1'b1;
        fc_stall_memwb_o = 1'b1;
    
    end

    if(cl_stall_i)begin
        fc_stall_if_o = 1'b1;
        // fc_stall_id_o = 1'b1;
        // fc_stall_ex_o = 1'b1;
        // fc_stall_mem_o = 1'b1;
        // fc_stall_wb_o = 1'b1;

        //fc_stall_ifid_o = 1'b1;
        // fc_stall_idex_o = 1'b1;
        // fc_stall_exmem_o = 1'b1;
        // fc_stall_memwb_o = 1'b1;
    end


    if(Icache_stall_flag == 1'b1)begin
        fc_stall_if_o = 1'b1;
        fc_stall_id_o = 1'b1;
        fc_stall_ex_o = 1'b1;
        fc_stall_mem_o = 1'b1;
        fc_stall_wb_o = 1'b1;

        fc_stall_ifid_o = 1'b1;
        fc_stall_idex_o = 1'b1;
        fc_stall_exmem_o = 1'b1;
        fc_stall_memwb_o = 1'b1;
    end

    if(Dcache_stall_flag == 1'b1)begin
        fc_stall_if_o = 1'b1;
        fc_stall_id_o = 1'b1;
        fc_stall_ex_o = 1'b1;
        fc_stall_mem_o = 1'b1;
        fc_stall_wb_o = 1'b1;

        fc_stall_ifid_o = 1'b1;
        fc_stall_idex_o = 1'b1;
        fc_stall_exmem_o = 1'b1;
        fc_stall_memwb_o = 1'b1;
    end

    else if(id_load_use_flag_i == 1'b1)begin
        fc_stall_if_o = 1'b1;
        fc_stall_ifid_o = 1'b1;
    end

end


//------------------- for flush
reg ex_branch_flag_buffer, id_jump_flag_buffer;

always@(posedge clk)begin
    if(rst_n == 1'b0)begin
        ex_branch_flag_buffer <= 1'b0;
        id_jump_flag_buffer <= 1'b0;
    end
    else begin
        ex_branch_flag_buffer <= ex_branch_flag_i;
        id_jump_flag_buffer <= id_jump_flag_i;
    end

end


assign fc_jump_flag_if_o = (~ex_branch_flag_buffer && ex_branch_flag_i) | (~id_jump_flag_buffer && id_jump_flag_i);   //需要上升沿，防止ex_branch持续为高，导致flag一直为高

assign fc_jump_pc_if_o = ex_branch_flag_i ? ex_branch_pc_i : 
                            id_jump_flag_i ? id_jump_pc_i : 32'h0;


always@(*)begin

    fc_flush_ifid_o = 1'b0;
    fc_flush_idex_o = 1'b0;
    fc_flush_exmem_o = 1'b0;
    fc_flush_memwb_o = 1'b0;
    fc_flush_id_o = 1'b0; 
    fc_flush_ex_o = 1'b0; 
    fc_flush_mem_o = 1'b0; 

    if(~id_jump_flag_buffer && id_jump_flag_i)begin  //jtype
        fc_flush_ifid_o = 1'b1;
        fc_flush_id_o = 1'b1;
    end
    else if(~ex_branch_flag_buffer && ex_branch_flag_i)begin //btype
        fc_flush_ifid_o = 1'b1;
        fc_flush_idex_o = 1'b1;
        fc_flush_id_o = 1'b1; 
    end
    else if(id_load_use_flag_i == 1'b1) begin
        fc_flush_idex_o = 1'b1;  // 推出一条pop指令,相当于该条指令被忽略
    end

    if(cl_stall_i)
        fc_flush_ifid_o =1'b1;
    
    
end


endmodule