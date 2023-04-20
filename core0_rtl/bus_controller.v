module bus_controller(

    input   wire                    clk,
    input   wire                    rst_n,

    //from Icache                 
    input   wire            [31:0]  Icache_addr_i,
    input   wire                    Icache_valid_req_i,

    //to Icache
    output  reg                     bc_Icache_ready_o,
    output  reg             [127:0] bc_Icache_data_o,

    //from Dcache
    input   wire                    Dcache_rd_req_i,
    input   wire            [31:0]  Dcache_rd_addr_i,

    input   wire                    Dcache_wb_req_i,
    input   wire            [31:0]  Dcache_wb_addr_i,
    input   wire            [127:0] Dcache_wb_data_i,

    //from ex
    input   wire                    ex_req_bus_i,
    input   wire                    ex_mem_rw_i,
    input   wire            [31:0]  ex_mem_addr_i,
    input   wire            [31:0]  ex_mem_data_i,

    //to mem
    output  reg                    bc_bus_ready_o,  //to mem and fc
    output  reg            [31:0]  bc_bus_data_o,

    //to Dcache
    output  reg                     bc_Dcache_ready_o,
    output  reg             [127:0] bc_Dcache_data_o,

    //to interface
    output  reg                     bc_valid_req_o,
    output  reg                     bc_rw_o,
    output  reg             [31:0]  bc_addr_o,
    output  reg             [127:0] bc_data_o, 

    //from interface
    input   wire            [127:0] axi_data_i,  //to axi controller
    input   wire                    axi_rd_over_i,
    input   wire                    axi_wr_over_i,

    input   wire                    core_WAIT_i,

    //to fc
    output  wire                    core_WAIT_bus_o, //stall Icache,Dcache         
    //from fc
    input   wire                    fc_jump_flag_Icache_i
);

assign core_WAIT_bus_o = core_WAIT_i;

//arbiter
reg [1:0] bus_user;   //1-Icache 2-Dcache 0-not using
reg bus_rw;
reg [31:0]  bus_addr;
reg [127:0] bus_data;


//reg_def
reg valid_req;

// reg r_core_wait; //等待CORE_WAIT下降沿
// wire transaction_again;

// always @(posedge M_AXI_ACLK) begin
//   if(M_AXI_ARESETN == 1'b0) 
//     r_core_wait <= 1'b0;
//   else 
//     r_core_wait <= core_WAIT;
// end

// assign transaction_again = ~core_WAIT && r_core_wait;



//FSM
localparam S_IDLE = 0;
localparam S_USING = 1;

reg user_bus;   //0-Dcache,1-UART或TIMER 不经过Dcache的访存

reg  State;


reg Icache_req_again;



always@(posedge clk)begin
    if(rst_n == 1'b0)begin
        State <= S_IDLE;
    
        bc_Icache_ready_o <= 1'b0;
        bc_Icache_data_o <= 128'b0;

        bc_Dcache_ready_o <= 1'b0;
        bc_Dcache_data_o <= 128'd0;

        bc_bus_ready_o <= 1'b0;
        bc_bus_data_o <= 32'd0;

        bc_valid_req_o <= 1'd0;
        bc_rw_o <= 1'd0;
        bc_addr_o <= 32'd0;
        bc_data_o <= 128'd0;


        bus_user <= 1'b0;
        bus_rw <= 1'b0; 
        bus_addr <= 32'd0;
        bus_data <= 128'd0;

        Icache_req_again <= 1'b0;

        user_bus <= 1'b0;
    
    end
    else begin
        case(State)
            S_IDLE:begin
                bc_Icache_ready_o <= 1'b0;
                bc_Dcache_ready_o <= 1'b0;
                bc_bus_ready_o <= 1'b0;

                bus_data <= 128'd0;
                

                if( (Icache_valid_req_i && ~fc_jump_flag_Icache_i)|| Dcache_rd_req_i || Dcache_wb_req_i || Icache_req_again || ex_req_bus_i)begin
                    
                    State <= S_USING;
                    valid_req <= 1'b1;

                    if( (Icache_req_again || (Icache_valid_req_i && ~fc_jump_flag_Icache_i) ) && (Dcache_rd_req_i || Dcache_wb_req_i || ex_req_bus_i))begin  //Dcache prior
                        bus_user <= 2'd2;
                        Icache_req_again <= 1'b1;
                    
                        if(Dcache_rd_req_i)begin
                            user_bus <= 1'b0;
                            bus_rw <= 1'b1;
                            bus_addr <= Dcache_rd_addr_i;
                        end
                        else if(Dcache_wb_req_i) begin
                            user_bus <= 1'b0;
                            bus_rw <= 1'b0;
                            bus_addr <= Dcache_wb_addr_i;
                            bus_data <= Dcache_wb_data_i;
                        end
                        else begin
                            user_bus <= 1'b1;

                            case(ex_mem_rw_i)
                                1'b0:begin
                                    bus_rw <= 1'b0;
                                    bus_addr <= ex_mem_addr_i;
                                    bus_data <= ex_mem_data_i;
                                end
                                1'b1:begin
                                    bus_rw <= 1'b1;
                                    bus_addr <= Dcache_rd_addr_i;
                                end

                            endcase
                        
                        end
                    end
                    else if(Dcache_rd_req_i || Dcache_wb_req_i || ex_req_bus_i)begin
                        bus_user <= 2'd2;
                    
                        if(Dcache_rd_req_i)begin
                            user_bus <= 1'b0;
                            bus_rw <= 1'b1;
                            bus_addr <= Dcache_rd_addr_i;
                        end
                        else if(Dcache_wb_req_i) begin
                            user_bus <= 1'b0;
                            bus_rw <= 1'b0;
                            bus_addr <= Dcache_wb_addr_i;
                            bus_data <= Dcache_wb_data_i;
                        end
                        else begin
                            user_bus <= 1'b1;

                            case(ex_mem_rw_i)
                                1'b0:begin
                                    bus_rw <= 1'b0;
                                    bus_addr <= ex_mem_addr_i;
                                    bus_data <= ex_mem_data_i;
                                end
                                1'b1:begin
                                    bus_rw <= 1'b1;
                                    bus_addr <= ex_mem_addr_i;
                                end

                            endcase
                        
                        end
                    end
                    else if(Icache_req_again)begin
                        Icache_req_again <= 1'b0;
                        bus_user <= 2'd1;
                        bus_rw <= 1'b1;
                        bus_addr <= Icache_addr_i;
                    end
                    else if(Icache_valid_req_i)begin
                        bus_user <= 2'd1;
                        bus_rw <= 1'b1;
                        bus_addr <= Icache_addr_i;
                    end
                end


            end
            

            S_USING:begin

                if(user_bus == 1'b1)begin           //若ex_bus与Icache同时req，ex_bus会比Icache早一个周期到达bc
                    if(Icache_valid_req_i)          //所以在第二个周期还应该判断是否ex与Icache请求冲突
                        Icache_req_again <= 1'b1;
                end



                if(valid_req)begin
                    valid_req <= 1'b0;

                    bc_valid_req_o <= 1'b1;
                    bc_rw_o <= bus_rw;
                    bc_addr_o <= bus_addr;
                    bc_data_o <= bus_data;

                end else
                    bc_valid_req_o <= 1'b0;

                if(axi_rd_over_i)begin

                    State <= S_IDLE;

                    case(bus_user)
                        2'd1:begin  //Icache
                            bc_Icache_ready_o <= 1'b1;
                            bc_Icache_data_o <= axi_data_i;
                            bus_user <= 2'd0;
                        end
                        2'd2:begin
                            if(user_bus == 1'b0)begin
                                bc_Dcache_ready_o <= 1'b1;
                                bc_Dcache_data_o <= axi_data_i;
                                bus_user <= 2'd0;
                            end 
                            else begin
                                bc_bus_ready_o <= 1'b1;
                                bc_bus_data_o <= axi_data_i[31:0];
                            end
                        end
                        default:;
                    endcase
            
                end

                if(axi_wr_over_i)begin

                    State <= S_IDLE;

                    if(user_bus == 1'b0)begin
                        bc_Dcache_ready_o <= 1'b1;
                    end 
                    else begin
                        bc_bus_ready_o <= 1'b1;
                    end

                    
                end
                

                
            
            
            end




        
            default:;   
        endcase
    
    
    end


end










endmodule