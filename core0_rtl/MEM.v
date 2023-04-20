module MEM (
    input   wire                    clk,
    input   wire                    rst_n,
    //from ex_mem_reg
    input   wire            [31:0]  exmem_reg_wdata_i,
    input   wire            [4:0]   exmem_reg_waddr_i,
    input   wire                    exmem_reg_we_i,

    input   wire            [31:0]  exmem_csr_wdata_i,
    input   wire            [11:0]  exmem_csr_waddr_i,
    input   wire                    exmem_csr_we_i,

    input   wire                    exmem_mtype_i,          
    input   wire                    exmem_mem_rw_i,        
    input   wire            [1:0]   exmem_mem_width_i,  
    input   wire            [31:0]  exmem_mem_addr_i,
    input   wire                    exmem_mem_rdtype_i,

    //to mem_wb_reg
    output  reg             [31:0]  mem_reg_wdata_o,
    output  wire            [4:0]   mem_reg_waddr_o,
    output  wire                    mem_reg_we_o,

    output  wire            [31:0]  mem_csr_wdata_o,
    output  wire            [11:0]  mem_csr_waddr_o,
    output  wire                    mem_csr_we_o,

    //from Dcache
    input   wire                    Dcache_ready_i,
    input   wire            [31:0]  Dcache_data_i,

    //from fc
    input   wire                    fc_stall_mem_i,
    input   wire                    fc_flush_mem_i,

    //from bc
    input   wire                    bc_bus_ready_i,
    input   wire            [31:0]  bc_bus_data_i
    

);

    assign mem_csr_wdata_o = exmem_csr_wdata_i;
    assign mem_csr_waddr_o = exmem_csr_waddr_i;
    assign mem_csr_we_o = exmem_csr_we_i;

  
    assign mem_reg_waddr_o = exmem_reg_waddr_i;
    assign mem_reg_we_o = exmem_reg_we_i;



    //------------for stall
    reg [31:0]  Data_Buffer;
    reg [1:0]        Dcache_in_Buffer;

    reg [31:0]  Buffer_out;                         //需要延迟等待，ex申请bc或Dcache时就stall住了，此时exmem无法获取ex_reg_addr等数据
                                                    //一直到stall为0,exmem才从ex获取，再下一个周期，MEM才得到正确值
    always@(posedge clk or negedge rst_n)begin
        if(rst_n == 1'b0)begin
            Data_Buffer <= 32'h0;
            Buffer_out <= 32'd0;
            Dcache_in_Buffer <= 1'b0;
        end

        //Icache stall and Dcache need give out data
        else if(fc_stall_mem_i == 1'b1 && (Dcache_ready_i == 1'b1 || bc_bus_ready_i == 1'b1))begin
            if(Dcache_ready_i)
                Data_Buffer <= Dcache_data_i;
            else 
                Data_Buffer <= bc_bus_data_i;
            Dcache_in_Buffer <= 2'd2;
            Buffer_out <= Data_Buffer;
        end
        else if(fc_stall_mem_i == 1'b1) begin//keep
            Dcache_in_Buffer <= Dcache_in_Buffer;
            Data_Buffer <= Data_Buffer;   
            Buffer_out <= Data_Buffer;
        end
        else if(fc_flush_mem_i == 1'b1)begin
            Dcache_in_Buffer <= 1'b0;
            Data_Buffer <= 32'h0;
        end
        else begin
            Data_Buffer <= Data_Buffer;
            Buffer_out <= Data_Buffer;
            
            if(Dcache_in_Buffer == 2'd2)
                Dcache_in_Buffer <= 2'd1;
            else if(Dcache_in_Buffer == 2'd1)
                Dcache_in_Buffer <= 2'd0;
            

        end
    end


    //-----------
    always@(*)begin
        if(exmem_mtype_i == 1'b1)begin
            if(Dcache_ready_i == 1'b1)begin
                case(exmem_mem_width_i)
                    2'b01: begin
                        case(exmem_mem_addr_i[1:0])
                            2'b00:begin
                                if(exmem_mem_rdtype_i == 1'd0)
                                    mem_reg_wdata_o = { {24{Dcache_data_i[7]}}, Dcache_data_i[7:0] };
                                else 
                                    mem_reg_wdata_o = { {24{1'd0}}, Dcache_data_i[7:0] };
                            end
                            2'b01:begin
                                if(exmem_mem_rdtype_i == 1'd0)
                                    mem_reg_wdata_o = { {24{Dcache_data_i[15]}}, Dcache_data_i[15:8] };
                                else 
                                    mem_reg_wdata_o = { {24{1'd0}}, Dcache_data_i[15:8] };
                            end
                            2'b10:begin
                                if(exmem_mem_rdtype_i == 1'd0)
                                    mem_reg_wdata_o = { {24{Dcache_data_i[23]}}, Dcache_data_i[23:16] };
                                else 
                                    mem_reg_wdata_o = { {24{1'd0}}, Dcache_data_i[23:16] };
                            end
                            2'b11:begin
                                if(exmem_mem_rdtype_i == 1'd0)
                                    mem_reg_wdata_o = { {24{Dcache_data_i[31]}}, Dcache_data_i[31:24] };
                                else 
                                    mem_reg_wdata_o = { {24{1'd0}}, Dcache_data_i[31:24] };
                            end
                            default:;
                        endcase
                    end
                    2'b10: begin
                        case(exmem_mem_addr_i[1:0])
                            2'b00:begin
                                if(exmem_mem_rdtype_i == 1'd0)
                                    mem_reg_wdata_o = { {24{Dcache_data_i[15]}}, Dcache_data_i[15:0] };
                                else 
                                    mem_reg_wdata_o = { {24{1'd0}}, Dcache_data_i[15:0] };
                            end
                            2'b10:begin
                                if(exmem_mem_rdtype_i == 1'd0)
                                    mem_reg_wdata_o = { {24{Dcache_data_i[31]}}, Dcache_data_i[31:16] };
                                else 
                                    mem_reg_wdata_o = { {24{1'd0}}, Dcache_data_i[31:16] };
                            end
                            default:;
                        endcase
                    end
                    
                    
                    2'b11: mem_reg_wdata_o = Dcache_data_i;
                    default: mem_reg_wdata_o = 32'h0;
                endcase
            end
            
            else if(bc_bus_ready_i == 1'b1) begin
                mem_reg_wdata_o = bc_bus_data_i;
            end
            else begin
                if(Dcache_in_Buffer == 2'b1) begin
                    case(exmem_mem_width_i)
                    2'b01: begin
                        case(exmem_mem_addr_i[1:0])
                            2'b00:begin
                                if(exmem_mem_rdtype_i == 1'd0)
                                    mem_reg_wdata_o = { {24{Buffer_out[7]}}, Buffer_out[7:0] };
                                else 
                                    mem_reg_wdata_o = { {24{1'd0}}, Buffer_out[7:0] };
                            end
                            2'b01:begin
                                if(exmem_mem_rdtype_i == 1'd0)
                                    mem_reg_wdata_o = { {24{Buffer_out[15]}}, Buffer_out[15:8] };
                                else 
                                    mem_reg_wdata_o = { {24{1'd0}}, Buffer_out[15:8] };
                            end
                            2'b10:begin
                                if(exmem_mem_rdtype_i == 1'd0)
                                    mem_reg_wdata_o = { {24{Buffer_out[23]}}, Buffer_out[23:16] };
                                else 
                                    mem_reg_wdata_o = { {24{1'd0}}, Buffer_out[23:16] };
                            end
                            2'b11:begin
                                if(exmem_mem_rdtype_i == 1'd0)
                                    mem_reg_wdata_o = { {24{Buffer_out[31]}}, Buffer_out[31:24] };
                                else 
                                    mem_reg_wdata_o = { {24{1'd0}}, Buffer_out[31:24] };
                            end
                            default:;
                        endcase
                    end
                    2'b10: begin
                        case(exmem_mem_addr_i[1:0])
                            2'b00:begin
                                if(exmem_mem_rdtype_i == 1'd0)
                                    mem_reg_wdata_o = { {24{Buffer_out[15]}}, Buffer_out[15:0] };
                                else 
                                    mem_reg_wdata_o = { {24{1'd0}}, Buffer_out[15:0] };
                            end
                            2'b10:begin
                                if(exmem_mem_rdtype_i == 1'd0)
                                    mem_reg_wdata_o = { {24{Buffer_out[31]}}, Buffer_out[31:16] };
                                else 
                                    mem_reg_wdata_o = { {24{1'd0}}, Buffer_out[31:16] };
                            end
                            default:;
                        endcase
                    end
                    
                    
                    2'b11: mem_reg_wdata_o = Buffer_out;
                    default: mem_reg_wdata_o = 32'h0;
                    endcase
                
                end
                else
                    mem_reg_wdata_o = mem_reg_wdata_o;   //重点 若=0 错误
            end
        end

        else
            mem_reg_wdata_o = exmem_reg_wdata_i;
    end








endmodule