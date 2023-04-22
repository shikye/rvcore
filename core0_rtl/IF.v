module IF(
    input                       clk,
    input                       rst_n,

    //from fc
    input   wire                fc_stall_if_i,  //流水线暂停

    input   wire                fc_jump_flag_if_i, //跳转
    input   wire        [31:0]  fc_jump_pc_if_i,
    
    //from clint
    input   wire                cl_int_i,
    input   wire        [31:0]  cl_addr_i,
    
    //to Icache, if_id_reg
    output  reg         [31:0]  if_pc_o,

    //to Icache
    output  reg                 if_req_Icache_o
);


reg start_flag; //need a start state
reg int;

always@(posedge clk or negedge rst_n)begin

        if(rst_n == 1'b0)begin      //start state
            if_pc_o <= 32'h0;
            if_req_Icache_o <= 1'b0;
            start_flag <= 1'b1;
            int <= 1'b0;
        end
        else if(start_flag == 1'b1)begin
            if_pc_o <= 32'h0;
            if_req_Icache_o <= 1'b1;
            start_flag <= 1'b0;
        end
        else if(cl_int_i == 1'b1)begin
            int <= 1'b1;
            if_pc_o <= cl_addr_i;
            if_req_Icache_o <= 1'b0;
            start_flag <= 1'b0;
        end
        else if(fc_jump_flag_if_i == 1'b1)begin  //priority of jump is higher than stall
            if_pc_o <= fc_jump_pc_if_i;             //when present inst need to stall
            if_req_Icache_o <= 1'b1;                //but last inst is a jump
            start_flag <= 1'b0;                     //present inst don't need to excute
        end

        else if(fc_stall_if_i == 1'b1)begin
            if_pc_o <= if_pc_o;      
            if_req_Icache_o <= 1'b0; 
            start_flag <= 1'b0;
        end
        
        else begin
            int <= 1'b0;
            if(int)
                if_pc_o <= if_pc_o;
            else 
                if_pc_o <= if_pc_o + 32'd4;
            if_req_Icache_o <= 1'b1;
            start_flag <= 1'b0;
        end
end












endmodule