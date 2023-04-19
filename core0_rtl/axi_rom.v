module axi_rom#
	(
		parameter                                   WIDTH_ID	    = 2,
		parameter                                   WIDTH_DA	    = 32,
		parameter                                   WIDTH_AD	    = 32
	)
	(
		input wire                                  S_AXI_ACLK      ,
		input wire                                  S_AXI_ARESETN   ,

        /*Write Address Channel*/
		input wire [WIDTH_ID-1 : 0]         S_AXI_AWID      ,
		input wire [WIDTH_AD-1 : 0]       S_AXI_AWADDR    ,
		input wire [3 : 0]                          S_AXI_AWLEN     ,
		input wire [2 : 0]                          S_AXI_AWSIZE    ,
		input wire [1 : 0]                          S_AXI_AWBURST   ,
		input wire                                  S_AXI_AWVALID   ,
		output wire                                 S_AXI_AWREADY   ,

        /*Write Data Channel*/
		input wire [WIDTH_DA-1 : 0]       S_AXI_WDATA     ,
		input wire [(WIDTH_DA/8)-1 : 0]   S_AXI_WSTRB     ,
		input wire                                  S_AXI_WLAST     ,
		input wire                                  S_AXI_WVALID    ,
		output wire                                 S_AXI_WREADY    ,

        /*Write Response (B) Channel*/
		output wire [WIDTH_ID-1 : 0]        S_AXI_BID       ,
		output wire [1 : 0]                         S_AXI_BRESP     ,
		output wire                                 S_AXI_BVALID    ,
		input wire                                  S_AXI_BREADY    ,

        /*Read Address Channel*/
		input wire [WIDTH_ID-1 : 0]         S_AXI_ARID      ,
		input wire [WIDTH_AD-1 : 0]       S_AXI_ARADDR    ,
		input wire [3 : 0]                          S_AXI_ARLEN     ,
		input wire [2 : 0]                          S_AXI_ARSIZE    ,
		input wire [1 : 0]                          S_AXI_ARBURST   ,
		input wire                                  S_AXI_ARVALID   ,
		output wire                                 S_AXI_ARREADY   ,

        /*Read Data Channel*/
		output wire [WIDTH_ID-1 : 0]        S_AXI_RID       ,
		output wire [WIDTH_DA-1 : 0]      S_AXI_RDATA     ,
		output wire [1 : 0]                         S_AXI_RRESP     ,
		output wire                                 S_AXI_RLAST     ,
		output wire                                 S_AXI_RVALID    ,
		input wire                                  S_AXI_RREADY    
);

/**********************参数***************************/

/**********************FSM************************/
//对主机状态
reg [1:0]                           W_state;

localparam  W_Idle  = 0;
localparam  W_Trans = 1;
localparam  W_Wait  = 2;


reg [1:0]                           R_state;

localparam  R_Idle  = 0;
localparam  R_Receive   = 1;

/**********************reg_def*************************/
reg [WIDTH_AD-1 : 0]  r_s_axi_awaddr                          ;
reg [7 : 0]                     r_s_axi_awlen                           ;
reg [7 : 0]                     r_wr_cnt                                ;

reg [WIDTH_AD-1 : 0]  r_s_axi_araddr                          ;
reg [7 : 0]                     r_s_axi_arlen                           ;
reg [7 : 0]                     r_rd_cnt                                ;

reg                             r_s_axi_rvalid                          ;
reg  [31:0]                           r_s_axi_rdata                           ;
reg                             r_s_axi_rlast                           ;

reg                             r_s_axi_bvalid                          ;

reg [7 : 0]                     r_ram[0 : 8191]                          ;
reg [12:0]                       r_ram_addr                              ;

/**********************组合逻辑***********************/
assign              S_AXI_AWREADY   = 1'b1                              ;

assign              S_AXI_WREADY    = 1'b1                              ;


assign              S_AXI_BID       = 'd0                               ;
assign              S_AXI_BRESP     = 'd0                               ;
assign              S_AXI_BVALID    = r_s_axi_bvalid                    ;

assign              S_AXI_ARREADY   = 1'b1                              ;

assign              S_AXI_RID       = 'd0                               ;
assign              S_AXI_RDATA     = r_s_axi_rdata                     ;
assign              S_AXI_RRESP     = 'd0                               ;
assign              S_AXI_RLAST     = r_s_axi_rlast                     ; 
assign              S_AXI_RVALID    = r_s_axi_rvalid                    ;

/**********************sequence***************************/




/*Write Transaction*/
always @(posedge S_AXI_ACLK) begin
    if(S_AXI_ARESETN == 1'b0) begin
      W_state <= W_Idle;
  
      r_s_axi_awaddr <= 32'd0;
      r_s_axi_awlen <= 'd0;
      r_wr_cnt <= 'd0;

      r_s_axi_bvalid <= 1'b0;
    end

    else begin
      case(W_state)
        W_Idle:begin
  
          if(S_AXI_AWVALID == 1'b1 && S_AXI_AWREADY== 1'b1) begin
  
            r_s_axi_awaddr <= S_AXI_AWADDR;
            r_s_axi_awlen <= S_AXI_AWLEN;

            r_ram_addr <= S_AXI_AWADDR[7:0];

            W_state <= W_Trans;
  
          end else
            W_state <= W_Idle;
        end
  
        W_Trans:begin
          
          if(S_AXI_WVALID == 1'b1 && S_AXI_WREADY == 1'b1)begin
            case(r_wr_cnt)
              2'd0:begin
                r_wr_cnt <= r_wr_cnt + 2'd1;

                r_ram[r_ram_addr + 0] <= S_AXI_WDATA[7:0];
                r_ram[r_ram_addr + 1] <= S_AXI_WDATA[15:8];
                r_ram[r_ram_addr + 2] <= S_AXI_WDATA[23:16];
                r_ram[r_ram_addr + 3] <= S_AXI_WDATA[31:24];
              end
              2'd1:begin
                r_wr_cnt <= r_wr_cnt + 2'd1;

                r_ram[r_ram_addr + 4 + 0] <= S_AXI_WDATA[7:0];
                r_ram[r_ram_addr + 4 + 1] <= S_AXI_WDATA[15:8];
                r_ram[r_ram_addr + 4 + 2] <= S_AXI_WDATA[23:16];
                r_ram[r_ram_addr + 4 + 3] <= S_AXI_WDATA[31:24];
              end
              2'd2:begin
                r_wr_cnt <= r_wr_cnt + 2'd1;

                r_ram[r_ram_addr + 8 + 0] <= S_AXI_WDATA[7:0];
                r_ram[r_ram_addr + 8 + 1] <= S_AXI_WDATA[15:8];
                r_ram[r_ram_addr + 8 + 2] <= S_AXI_WDATA[23:16];
                r_ram[r_ram_addr + 8 + 3] <= S_AXI_WDATA[31:24];
              end
              2'd3:begin  //恢复
                r_ram[r_ram_addr + 12 + 0] <= S_AXI_WDATA[7:0];
                r_ram[r_ram_addr + 12 + 1] <= S_AXI_WDATA[15:8];
                r_ram[r_ram_addr + 12 + 2] <= S_AXI_WDATA[23:16];
                r_ram[r_ram_addr + 12 + 3] <= S_AXI_WDATA[31:24];

                r_wr_cnt <= 2'd0;
                
                r_s_axi_bvalid <= 1'b1;
                W_state <= W_Wait;


              end
              default:;
            endcase
          end
  
        end
  
        W_Wait:begin
          if(S_AXI_BVALID == 1'b1 && S_AXI_BREADY == 1'b1)begin
  
            W_state <= W_Idle;
            r_s_axi_bvalid <= 1'b0;

          end
        
        end
      
        default:;
      endcase
    
    end
  
  end
  
  
  
  
  /*Read Transaction*/
  always@(posedge S_AXI_ACLK)begin
    if(S_AXI_ARESETN == 1'b0) begin
        R_state <= R_Idle;
  
        r_s_axi_araddr <= 32'd0;
        r_s_axi_arlen <= 'd0;
        
        r_rd_cnt <= 'd0;
        r_s_axi_rvalid <= 'd0;
        r_s_axi_rdata <= 'd0;
        r_s_axi_rlast <= 'd0;
    end
  
    else begin
    
      case(R_state)
        R_Idle:begin

          r_s_axi_rvalid <= 1'b0;
          r_s_axi_rlast <= 1'b0;

          if(S_AXI_ARVALID == 1'b1 && S_AXI_ARVALID == 1'b1) begin
            r_s_axi_araddr <= S_AXI_ARADDR;
            r_s_axi_arlen <= S_AXI_ARLEN;

            r_ram_addr <= S_AXI_ARADDR[12:0];

            R_state <= R_Receive;

            r_s_axi_rvalid <= 1'b1;

            r_s_axi_rdata[7:0] <=   r_ram[S_AXI_ARADDR[12:0] + 0];
            r_s_axi_rdata[15:8] <=  r_ram[S_AXI_ARADDR[12:0] + 1];
            r_s_axi_rdata[23:16] <= r_ram[S_AXI_ARADDR[12:0] + 2];
            r_s_axi_rdata[31:24] <= r_ram[S_AXI_ARADDR[12:0] + 3];



            r_rd_cnt <= r_rd_cnt + 2'd1;
          end
          else 
            R_state <= R_Idle;
        end
  
  
        R_Receive:begin
          if(S_AXI_RVALID == 1'b1 && S_AXI_RREADY == 1'b1) begin
            case(r_rd_cnt)
              
              'd1:begin
                r_s_axi_rdata[7:0]    <=  r_ram[S_AXI_ARADDR[12:0] + 4 + 0];
                r_s_axi_rdata[15:8]   <=  r_ram[S_AXI_ARADDR[12:0] + 4 + 1];
                r_s_axi_rdata[23:16]  <=  r_ram[S_AXI_ARADDR[12:0] + 4 + 2];
                r_s_axi_rdata[31:24]  <=  r_ram[S_AXI_ARADDR[12:0] + 4 + 3];
                r_rd_cnt <= r_rd_cnt + 2'd1;
              end
              'd2:begin
                r_s_axi_rdata[7:0]    <=  r_ram[S_AXI_ARADDR[12:0] + 8 + 0];
                r_s_axi_rdata[15:8]   <=  r_ram[S_AXI_ARADDR[12:0] + 8 + 1];
                r_s_axi_rdata[23:16]  <=  r_ram[S_AXI_ARADDR[12:0] + 8 + 2];
                r_s_axi_rdata[31:24]  <=  r_ram[S_AXI_ARADDR[12:0] + 8 + 3];
                r_rd_cnt <= r_rd_cnt + 2'd1;

              end
              'd3:begin
                r_s_axi_rdata[7:0]    <=  r_ram[S_AXI_ARADDR[12:0] + 12 + 0];
                r_s_axi_rdata[15:8]   <=  r_ram[S_AXI_ARADDR[12:0] + 12 + 1];
                r_s_axi_rdata[23:16]  <=  r_ram[S_AXI_ARADDR[12:0] + 12 + 2];
                r_s_axi_rdata[31:24]  <=  r_ram[S_AXI_ARADDR[12:0] + 12 + 3];

                r_s_axi_rlast <= 1'b1;

                r_rd_cnt <= 'd0;
                R_state <= R_Idle;
          
              end

              default:;
            endcase
          
          
          end
              
        end
      
        default:;
      endcase
    
    
    end
  
  end


endmodule
