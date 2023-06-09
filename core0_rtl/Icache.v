//2-way 8-set 
//Cache_Block:16 Byte,Cache_line:16 line
//Cache Memory Mapping:| Tag | Index | Block Offset | 2'b00 -- 4bytes each time
//                       25      3          2  
//Tag Unit:|Valid|Replace|Tag|
//            1      1    25
//Get 4 Btye for each time


//read sy
//!!!!!!!write and read sy, but hit can be get instantly
module Icache (
    input   wire                    clk,
    input   wire                    rst_n,

    //from if
    input   wire            [31:0]  if_pc_i, 
    input   wire                    if_req_Icache_i,
    
    
    //to id
    output  reg             [31:0]  Icache_inst_o,

    //to fc
    output  reg                     Icache_ready_o,
    output  wire                    Icache_hit_o,

    //from fc
    input   wire                    fc_jump_flag_Icache_i,
    input   wire                    fc_stall_Icache_i,
    
    //to bus_controller
    output  reg             [31:0]  Icache_addr_o,
    output  reg                     Icache_valid_req_o,

    //from bus_controller
    input   wire                    bc_Icache_ready_i,
    input   wire            [127:0] bc_Icache_data_i
);
    
//FSM
localparam Idle_or_Compare_Tag  = 0; //Compare and Give data to core
localparam Read_from_Mem        = 1;


reg cur_state;


//function mapping
localparam Tag_Width        = 25 - 1;
localparam Valid            = 26;
localparam Replace          = 25;


//Data_Block and Tag_Array
reg [127:0] ICache_Data_Block [0:15];
reg [26:0]  ICache_Tag_Array  [0:15];

//Mapping Decord
wire [24:0] Icache_tag   = if_pc_i[31:7];
wire [3:0]  Icache_index = {{1'b0},if_pc_i[6:4]};   // when Icache_index 3bits, if << , will overflow,Icache_index should be 4bits.
wire [1:0]  Icache_off   = if_pc_i[3:2];     //notice the width!!! [3:2]

reg [24:0] Tag_buffer;
reg [1:0] Read_off;
reg [3:0] Index_off;



//hit --regardless of ready
wire [1:0] ICache_Tag_hit;
assign ICache_Tag_hit[0] = ( (Icache_tag == ICache_Tag_Array[Icache_index << 1][Tag_Width:0]) && ICache_Tag_Array[Icache_index << 1][Valid] == 1'b1 );
assign ICache_Tag_hit[1] = ( (Icache_tag == ICache_Tag_Array[(Icache_index << 1) + 1][Tag_Width:0]) && ICache_Tag_Array[(Icache_index << 1) + 1][Valid] == 1'b1 );

assign Icache_hit_o              = (ICache_Tag_hit != 2'b00);



//replace algorithm
reg         victim_number;


//core_wait and req again
reg         req_again;


//initial
always @(*) begin
    if(rst_n == 1'b0)begin
        ICache_Tag_Array[0]    = 27'h0;
        ICache_Tag_Array[1]    = 27'h0;
        ICache_Tag_Array[2]    = 27'h0;
        ICache_Tag_Array[3]    = 27'h0;
        ICache_Tag_Array[4]    = 27'h0;
        ICache_Tag_Array[5]    = 27'h0;
        ICache_Tag_Array[6]    = 27'h0;
        ICache_Tag_Array[7]    = 27'h0;
        ICache_Tag_Array[8]    = 27'h0;
        ICache_Tag_Array[9]    = 27'h0;
        ICache_Tag_Array[10]   = 27'h0;
        ICache_Tag_Array[11]   = 27'h0;
        ICache_Tag_Array[12]   = 27'h0;
        ICache_Tag_Array[13]   = 27'h0;
        ICache_Tag_Array[14]   = 27'h0;
        ICache_Tag_Array[15]   = 27'h0;
    end
end




//FSM
always @(posedge clk or negedge rst_n) begin   
    if(rst_n == 1'b0)begin
        Icache_inst_o <= 32'h0;
        
        Icache_ready_o <= 1'b0;
        
        Icache_addr_o <= 32'h0;
        Icache_valid_req_o <= 1'b0;

        Read_off <= 2'b0;

        req_again <= 1'b0;

        cur_state <= Idle_or_Compare_Tag;
    end 
    else begin

        case(cur_state)
            Idle_or_Compare_Tag:begin
            

                if(fc_jump_flag_Icache_i == 1'b1) begin  //btype or jtype  --to Idle state, wait the new pc

                    cur_state <= Idle_or_Compare_Tag;
                    Icache_ready_o <= 1'b0;
                
                end 
                else begin
                    if(fc_stall_Icache_i == 1'b1)begin
                        req_again <= 1'b1;
                        Icache_ready_o <= 1'b0;
                    end

                    else if(if_req_Icache_i == 1'b1 || req_again == 1'b1)begin
                        req_again <= 1'b0;

                        if(Icache_hit_o == 1'b1)begin   //read hit then change Replace

                            cur_state <= Idle_or_Compare_Tag;
                            Icache_valid_req_o <= 1'b0;
                            Icache_ready_o <= 1'b1;


                            if(ICache_Tag_hit[0] == 1'b1) begin

                                case(Icache_off)
                                    2'b00:Icache_inst_o <= ICache_Data_Block[Icache_index << 1][31:0];
                                    2'b01:Icache_inst_o <= ICache_Data_Block[Icache_index << 1][63:32];
                                    2'b10:Icache_inst_o <= ICache_Data_Block[Icache_index << 1][95:64];
                                    2'b11:Icache_inst_o <= ICache_Data_Block[Icache_index << 1][127:96];
                                    default:Icache_inst_o <= 32'h0;
                                endcase

                                ICache_Tag_Array[Icache_index << 1][Replace] <= 1'b0;
                                ICache_Tag_Array[(Icache_index << 1) + 1][Replace] <= 1'b1;
                            end

                            else begin

                                case(Icache_off)
                                    2'b00:Icache_inst_o <= ICache_Data_Block[(Icache_index << 1) + 1][31:0];
                                    2'b01:Icache_inst_o <= ICache_Data_Block[(Icache_index << 1) + 1][63:32];
                                    2'b10:Icache_inst_o <= ICache_Data_Block[(Icache_index << 1) + 1][95:64];
                                    2'b11:Icache_inst_o <= ICache_Data_Block[(Icache_index << 1) + 1][127:96];
                                    default:Icache_inst_o <= 32'h0;
                                endcase
                                
                                ICache_Tag_Array[Icache_index << 1][Replace] <= 1'b1;
                                ICache_Tag_Array[(Icache_index << 1) + 1][Replace] <= 1'b0;
                            end
                        end

                        else begin                    //Cache Miss
                        //1.Replace 2.Change Tag  -- should change when write in, read mem stage

                            Icache_valid_req_o <= 1'b1;
                            Icache_addr_o <= (if_pc_i >> 4) << 4;

                            Icache_ready_o <= 1'b0;

                            cur_state <= Read_from_Mem;

                            Read_off <= Icache_off;

                            Index_off <= Icache_index;

                            Tag_buffer <= Icache_tag;

                            case( {ICache_Tag_Array[(Icache_index << 1) + 1][Replace],ICache_Tag_Array[Icache_index << 1][Replace]} )
                                2'b00:begin
                                    victim_number <= 1'b0;
                                end
                                2'b01:begin
                                    victim_number <= 1'b0;
                                end
                                2'b10:begin
                                    victim_number <= 1'b1;
                                end
                                default:begin
                                    victim_number = 1'b0;
                                end
                            endcase
                        end
                    end
                    
                    


                    else begin    //no valid req
                        cur_state <= Idle_or_Compare_Tag;

                        Icache_ready_o <= 1'b0;
                        Icache_inst_o <= 32'h0;

                    end
                
                end

            end


        Read_from_Mem:begin
            // Icache_valid_req_o = 1'b1;            valid should be 1 for only 1 cycle
            // Icache_addr_o = (if_pc_i >> 4) << 4;
            Icache_valid_req_o <= 1'b0; //valid for one cycle

            if(fc_jump_flag_Icache_i == 1'b1) begin  //btype or jtype  --need to change to jump pc

                cur_state <= Idle_or_Compare_Tag;

                // if(Icache_hit_o == 1'b1)begin   //read hit then change Replace

                //         cur_state <= Idle_or_Compare_Tag;
                //         Icache_valid_req_o <= 1'b0;
                //         Icache_ready_o <= 1'b1;


                //         if(ICache_Tag_hit[0] == 1'b1) begin

                //             case(Icache_off)
                //                 2'b00:Icache_inst_o <= ICache_Data_Block[Icache_index << 1][31:0];
                //                 2'b01:Icache_inst_o <= ICache_Data_Block[Icache_index << 1][63:32];
                //                 2'b10:Icache_inst_o <= ICache_Data_Block[Icache_index << 1][95:64];
                //                 2'b11:Icache_inst_o <= ICache_Data_Block[Icache_index << 1][127:96];
                //                 default:Icache_inst_o <= 32'h0;
                //             endcase

                //             ICache_Tag_Array[Icache_index << 1][Replace] <= 1'b0;
                //             ICache_Tag_Array[(Icache_index << 1) + 1][Replace] <= 1'b1;
                //         end

                //         else begin

                //             case(Icache_off)
                //                 2'b00:Icache_inst_o <= ICache_Data_Block[(Icache_index << 1) + 1][31:0];
                //                 2'b01:Icache_inst_o <= ICache_Data_Block[(Icache_index << 1) + 1][63:32];
                //                 2'b10:Icache_inst_o <= ICache_Data_Block[(Icache_index << 1) + 1][95:64];
                //                 2'b11:Icache_inst_o <= ICache_Data_Block[(Icache_index << 1) + 1][127:96];
                //                 default:Icache_inst_o <= 32'h0;
                //             endcase
                            
                //             ICache_Tag_Array[Icache_index << 1][Replace] <= 1'b1;
                //             ICache_Tag_Array[(Icache_index << 1) + 1][Replace] <= 1'b0;
                //         end
                // end

                // else begin                    //Cache Miss
                // //1.Replace 2.Change Tag  -- should change when write in, read mem stage

                //     Icache_valid_req_o <= 1'b1;
                //     Icache_addr_o <= (if_pc_i >> 4) << 4;

                //     Icache_ready_o <= 1'b0;

                //     cur_state <= Read_from_Mem;

                //     Read_off <= Icache_off;

                //     Index_off <= Icache_index;

                //     Tag_buffer <= Icache_tag;


                //     case( {ICache_Tag_Array[(Icache_index << 1) + 1][Replace],ICache_Tag_Array[Icache_index << 1][Replace]} )
                //         2'b00:begin
                //             victim_number <= 1'b0;
                //         end
                //         2'b01:begin
                //             victim_number <= 1'b0;
                //         end
                //         2'b10:begin
                //             victim_number <= 1'b1;
                //         end
                //         default:begin
                //             victim_number = 1'b0;
                //         end
                //     endcase
                // end
            
            end
                

            else begin

                if(bc_Icache_ready_i == 1'b1) begin //set valid
                    ICache_Data_Block[(Index_off << 1) + victim_number] <= bc_Icache_data_i;
                    ICache_Tag_Array[(Index_off << 1) + victim_number][Valid] <= 1'b1;

                    Icache_ready_o <= 1'b1;

                    case(Read_off)
                        2'b00:Icache_inst_o <= bc_Icache_data_i[31:0];
                        2'b01:Icache_inst_o <= bc_Icache_data_i[63:32];
                        2'b10:Icache_inst_o <= bc_Icache_data_i[95:64];
                        2'b11:Icache_inst_o <= bc_Icache_data_i[127:96];
                        default:Icache_inst_o <= 32'h0;
                    endcase

                    if(victim_number == 1'b0) begin
                        ICache_Tag_Array[Index_off << 1][Replace] <= 1'b0;
                        ICache_Tag_Array[(Index_off << 1) + 1][Replace] <= 1'b1;
                        ICache_Tag_Array[Index_off << 1][Tag_Width:0] <= Tag_buffer;
                    end 
                    else begin
                        ICache_Tag_Array[Index_off << 1][Replace] <= 1'b1;
                        ICache_Tag_Array[(Index_off << 1) + 1][Replace] <= 1'b0;
                        ICache_Tag_Array[(Index_off << 1) + 1][Tag_Width:0] <= Tag_buffer;
                    end


                    cur_state <= Idle_or_Compare_Tag;
                end
                else begin
                    Icache_ready_o <= 1'b0; 
                    cur_state <= Read_from_Mem;  
                end

            end
        end

        default: begin
            cur_state <= Idle_or_Compare_Tag;
            Icache_ready_o <= 1'b0; 
        end
    endcase
    
    
    end

end

endmodule