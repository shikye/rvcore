module axi_m#
(
    parameter  SLV_ADDR_BASE	= 32'h00000000,
    parameter integer BURST_LEN	= 4,
    parameter integer BURST_TYPE	= 4,     //2'b00 FIXED, 2'b01 INCR
    parameter integer WIDTH_ID	= 1,
    parameter integer WIDTH_AD	= 32,
    parameter integer WIDTH_DA	= 32
)
(

    input   wire                                    M_AXI_ACLK,
    input   wire                                    M_AXI_ARESETN,


    input   wire                                    Rvcore_valid_req_i,
    input   wire                                    Rvcore_rw_i,
    input   wire    [31:0]                          Rvcore_addr_i,
    input   wire    [127:0]                         Rvcore_data_i, 

    output  reg     [127:0]                         axi_data_o,  //to axi controller
    output  reg                                     axi_rd_over_o,
    output  reg                                     axi_wr_over_o,

    input   wire                                    core_WAIT_i,
    output  wire                                    core_WAIT_o,


    /*Write Address Channel*/
    output  wire    [WIDTH_ID-1 : 0]                M_AXI_AWID,
    output  wire    [WIDTH_AD-1 : 0]                M_AXI_AWADDR,
    output  wire    [3 : 0]                         M_AXI_AWLEN,
    output  wire    [2 : 0]                         M_AXI_AWSIZE,
    output  wire    [1 : 0]                         M_AXI_AWBURST,
    output  wire                                    M_AXI_AWVALID,
    input   wire                                    M_AXI_AWREADY,
    
    /*Write Data Channel*/
    output  wire    [WIDTH_DA-1 : 0]                M_AXI_WDATA,
    output  wire    [WIDTH_DA/8-1 : 0]              M_AXI_WSTRB,
    output  wire                                    M_AXI_WLAST,
    output  wire                                    M_AXI_WVALID,
    input   wire                                    M_AXI_WREADY,

    /*Write Response (B) Channel*/
    input   wire    [WIDTH_ID-1 : 0]                M_AXI_BID,
    input   wire    [1 : 0]                         M_AXI_BRESP,
    input   wire                                    M_AXI_BVALID,
    output  wire                                    M_AXI_BREADY,

    /*Read Address Channel*/
    output  wire    [WIDTH_ID-1 : 0]                M_AXI_ARID,
    output  wire    [WIDTH_AD-1 : 0]                M_AXI_ARADDR,
    output  wire    [3 : 0]                         M_AXI_ARLEN,
    output  wire    [2 : 0]                         M_AXI_ARSIZE,
    output  wire    [1 : 0]                         M_AXI_ARBURST,
    output  wire                                    M_AXI_ARVALID,
    input   wire                                    M_AXI_ARREADY,

    /*Read Data Channel*/
    input   wire    [WIDTH_ID-1 : 0]                M_AXI_RID,
    input   wire    [WIDTH_DA-1 : 0]                M_AXI_RDATA,
    input   wire    [1 : 0]                         M_AXI_RRESP,
    input   wire                                    M_AXI_RLAST,
    input   wire                                    M_AXI_RVALID,
    output  wire                                    M_AXI_RREADY
);

assign core_WAIT_o = core_WAIT_i;


/********************FSM***********************************/

reg [1:0]                           W_state;

localparam  W_Idle  = 0;
localparam  W_Trans = 1;
localparam  W_Wait  = 2;


reg [1:0]                           R_state;

localparam  R_Idle  = 0;
localparam  R_Receive   = 1;

/**********************************************************/
    function integer clogb2 (input integer bit_depth);              
	  begin                                                           
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
	      bit_depth = bit_depth >> 1;                                 
	    end                                                           
	endfunction

/*********************reg_def*******************************/
reg [WIDTH_AD - 1 : 0]              r_m_axi_awaddr;
reg                                 r_m_axi_awvalid;

reg [WIDTH_DA - 1 : 0]              r_m_axi_wdata;
reg                                 r_m_axi_wlast;
reg                                 r_m_axi_wvalid;

reg                                 r_m_axi_bready;

reg [WIDTH_AD - 1 : 0]              r_m_axi_araddr;
reg                                 r_m_axi_arvalid;

reg                                 r_m_axi_rready;

reg [2:0]                           r_wburst_cnt;
reg [127:0]                         r_wdata;

reg [2:0]                           r_rburst_cnt;




/*********************combination***************************/
assign M_AXI_AWID       = 'd0;
assign M_AXI_AWLEN      = BURST_LEN;
assign M_AXI_AWSIZE     = clogb2(WIDTH_DA/8 - 1);
assign M_AXI_AWBURST    = BURST_TYPE;
assign M_AXI_AWADDR     = r_m_axi_awaddr;
assign M_AXI_AWVALID    = r_m_axi_awvalid;


assign M_AXI_WSTRB      = {(WIDTH_DA/8-1 ){1'b1}};
assign M_AXI_WDATA      = r_m_axi_wdata;
assign M_AXI_WLAST      = r_m_axi_wlast;
assign M_AXI_WVALID     = r_m_axi_wvalid;


assign M_AXI_BREADY     = 1'b1;


assign M_AXI_ARID       = 'd0;
assign M_AXI_ARLEN      = BURST_LEN;
assign M_AXI_ARSIZE     = clogb2(WIDTH_DA/8 - 1);
assign M_AXI_ARBURST    = BURST_TYPE;       
assign M_AXI_ARADDR     = r_m_axi_araddr;
assign M_AXI_ARVALID    = r_m_axi_arvalid;


assign M_AXI_RREADY     = 1'b1;


/*********************sequence******************************/


/*Write Transaction*/
always @(posedge M_AXI_ACLK) begin
  if(M_AXI_ARESETN == 1'b0) begin
    W_state <= W_Idle;

    r_m_axi_wvalid <= 1'b0;
    r_m_axi_awaddr <= 32'h0;

    r_wdata <= 128'b0;
    r_wburst_cnt <= 2'd0;
    r_m_axi_wlast <= 1'b0;

    axi_wr_over_o <= 1'b0;


  end
  else begin
    case(W_state)
      W_Idle:begin

        axi_wr_over_o <= 1'b0;

        if(M_AXI_AWVALID == 1'b1 && M_AXI_AWREADY == 1'b1)begin
          r_m_axi_awvalid <= 1'b0;

          r_m_axi_wvalid <= 1'b1;
          r_m_axi_wdata <= Rvcore_data_i[31:0];

          W_state <= W_Trans;
        end
        else if( (Rvcore_valid_req_i == 1'b1 || transaction_again) && Rvcore_rw_i == 1'b0) begin

          r_m_axi_awvalid <= 1'b1;
          r_m_axi_awaddr <= Rvcore_addr_i;

          r_wdata <= Rvcore_data_i;

        end
        else begin
          W_state <= W_Idle;
        end
      end

      W_Trans:begin
        
        if(M_AXI_WVALID == 1'b1 && M_AXI_WREADY == 1'b1)begin
          case(r_wburst_cnt)
            2'd0:begin
              r_wburst_cnt <= r_wburst_cnt + 2'd1;
              r_m_axi_wdata <= r_wdata[63:32];
            end
            2'd1:begin
              r_wburst_cnt <= r_wburst_cnt + 2'd1;
              r_m_axi_wdata <= r_wdata[95:64];
            end
            2'd2:begin
              r_wburst_cnt <= r_wburst_cnt + 2'd1;
              r_m_axi_wdata <= r_wdata[127:96];

              r_m_axi_wlast <= 1'b1;
            end
            2'd3:begin  //恢复
              r_wburst_cnt <= 2'd0;
              r_m_axi_wlast <= 1'b0;

              r_m_axi_wvalid <= 1'b0;

              W_state <= W_Wait;
            end
            default:;
          endcase
        end

      end

      W_Wait:begin
        if(M_AXI_BVALID == 1'b1 && M_AXI_BREADY == 1'b1)begin

          W_state <= W_Idle;
          axi_wr_over_o <= 1'b1;

        end
      
      end
    
      default:;
    endcase
  
  
  
  end

end




/*Read Transaction*/
always@(posedge M_AXI_ACLK)begin
  if(M_AXI_ARESETN == 1'b0) begin
    R_state <= R_Idle;

    r_m_axi_araddr <= 32'h0;
    r_m_axi_arvalid <= 1'b0;

    axi_rd_over_o <= 1'b0;
    axi_data_o <= 128'h0;

    r_rburst_cnt <= 2'd0;
  end

  else begin
  
    case(R_state)
      R_Idle:begin

        axi_rd_over_o <= 1'b0;

        if((Rvcore_valid_req_i == 1'b1 || transaction_again) && Rvcore_rw_i == 1'b1) begin
          r_m_axi_araddr <= Rvcore_addr_i;
          r_m_axi_arvalid <= 1'b1;
        end
        else if(M_AXI_ARVALID == 1'b1 && M_AXI_ARREADY == 1'b1)begin
          r_m_axi_arvalid <= 1'b0;

          R_state <= R_Receive;
        
        end
        else 
          R_state <= R_Idle;
      end


      R_Receive:begin
        if(M_AXI_RVALID == 1'b1 && M_AXI_RREADY == 1'b1) begin
          case(r_rburst_cnt)
            2'd0:begin
              axi_data_o <= {axi_data_o[127:32], M_AXI_RDATA};
              r_rburst_cnt <= r_rburst_cnt + 2'd1;
            end
            2'd1:begin
              axi_data_o <= {axi_data_o[127:64], M_AXI_RDATA, axi_data_o[31:0]};
              r_rburst_cnt <= r_rburst_cnt + 2'd1;
            end
            2'd2:begin
              axi_data_o <= {axi_data_o[127:96], M_AXI_RDATA, axi_data_o[63:0]};
              r_rburst_cnt <= r_rburst_cnt + 2'd1;
            end
            2'd3:begin
              axi_data_o <= {M_AXI_RDATA, axi_data_o[95:0]};
              r_rburst_cnt <= 2'd0;

              axi_rd_over_o <= 1'b1;

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