module if_id_reg (
    input   wire                    clk,
    input   wire                    rst_n,

    //from IF
    input   wire            [31:0]  if_pc_i,

    //from fc
    input   wire                    fc_flush_ifid_i,
    input   wire                    fc_stall_ifid_i,

    //to ID
    output  reg             [31:0]  ifid_pc_o    
);


    always @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)begin
            ifid_pc_o <= 32'h0;
        end
        else if(fc_stall_ifid_i == 1'b1) begin
            ifid_pc_o <= ifid_pc_o;
        end 
        else if(fc_flush_ifid_i == 1'b1) begin
            ifid_pc_o <= 32'h0;
        end
        else begin 
            ifid_pc_o <= if_pc_i;
        end
    end



endmodule