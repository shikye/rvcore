module timer#                 //timer的访问不能经过Cache
	(
		parameter                                   WIDTH_ID	    = 2,
		parameter                                   WIDTH_DA	    = 32,
		parameter                                   WIDTH_AD	    = 32
	)
	(
		input wire                                  S_AXI_ACLK      ,
		input wire                                  S_AXI_ARESETN   ,

        /*Write Address Channel*/
		input wire [WIDTH_ID-1 : 0]                 S_AXI_AWID      ,
		input wire [WIDTH_AD-1 : 0]                 S_AXI_AWADDR    ,
		input wire [3 : 0]                          S_AXI_AWLEN     ,
		input wire [2 : 0]                          S_AXI_AWSIZE    ,
		input wire [1 : 0]                          S_AXI_AWBURST   ,
		input wire                                  S_AXI_AWVALID   ,
		output wire                                 S_AXI_AWREADY   ,

        /*Write Data Channel*/
		input wire [WIDTH_DA-1 : 0]                 S_AXI_WDATA     ,
		input wire [(WIDTH_DA/8)-1 : 0]             S_AXI_WSTRB     ,
		input wire                                  S_AXI_WLAST     ,
		input wire                                  S_AXI_WVALID    ,
		output wire                                 S_AXI_WREADY    ,

        /*Write Response (B) Channel*/
		output wire [WIDTH_ID-1 : 0]                S_AXI_BID       ,
		output wire [1 : 0]                         S_AXI_BRESP     ,
		output wire                                 S_AXI_BVALID    ,
		input wire                                  S_AXI_BREADY    ,

        /*Read Address Channel*/
		input wire [WIDTH_ID-1 : 0]                 S_AXI_ARID      ,
		input wire [WIDTH_AD-1 : 0]                 S_AXI_ARADDR    ,
		input wire [3 : 0]                          S_AXI_ARLEN     ,
		input wire [2 : 0]                          S_AXI_ARSIZE    ,
		input wire [1 : 0]                          S_AXI_ARBURST   ,
		input wire                                  S_AXI_ARVALID   ,
		output wire                                 S_AXI_ARREADY   ,

        /*Read Data Channel*/
		output wire [WIDTH_ID-1 : 0]                S_AXI_RID       ,
		output wire [WIDTH_DA-1 : 0]                S_AXI_RDATA     ,
		output wire [1 : 0]                         S_AXI_RRESP     ,
		output wire                                 S_AXI_RLAST     ,
		output wire                                 S_AXI_RVALID    ,
		input wire                                  S_AXI_RREADY    ,



        output  wire                                interupt_o
);



    localparam REG_STATE = 4'd0;
    localparam REG_COUNT = 4'd4;
    localparam REG_VALUE = 4'd8;   //触发值



    //control regs


    //[0]:count enable
    //[1]:interupt enable
    //[2]:trigger  写清零
    reg[31:0] timer_state;                 //0x00

    reg[31:0] timer_count;                 //0x04     ro

    reg[31:0] timer_value;                 //0x08


    assign interupt_o = (timer_state[1] && timer_state[2]) ? 1'd1 : 1'd0;





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
    reg [WIDTH_AD-1 : 0]            r_s_axi_awaddr                          ;
    reg [7 : 0]                     r_s_axi_awlen                           ;
    
    reg [WIDTH_AD-1 : 0]            r_s_axi_araddr                          ;
    reg [7 : 0]                     r_s_axi_arlen                           ;
    
    reg                             r_s_axi_rvalid                          ;
    reg  [31:0]                     r_s_axi_rdata                           ;
    reg                             r_s_axi_rlast                           ;
    
    reg                             r_s_axi_bvalid                          ;
    
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





    //timer_counter
    always@(posedge S_AXI_ACLK)begin
        if(S_AXI_ARESETN == 1'd0)begin
            timer_count <= 32'd0;
        end
        else begin
            if(timer_state[0])begin


                if(timer_count <= timer_value)
                    timer_count <= timer_count + 32'd1;
                else 
                    timer_count <= 32'd0;
                    
            
            end
            else begin
                timer_count <= 32'd0;

            end
        end
    end

    





    /*Write Transaction*/
always @(posedge S_AXI_ACLK) begin
    if(S_AXI_ARESETN == 1'b0) begin
      W_state <= W_Idle;
  
      r_s_axi_awaddr <= 32'd0;
      r_s_axi_awlen <= 'd0;
      r_s_axi_bvalid <= 1'b0;

      timer_state <= 32'd0;
      timer_count <= 32'd0;
      timer_value <= 32'd0;

    end

    else begin
      case(W_state)
        W_Idle:begin
  
          if(S_AXI_AWVALID == 1'b1 && S_AXI_AWREADY== 1'b1) begin
  
            r_s_axi_awaddr <= S_AXI_AWADDR;
            r_s_axi_awlen <= S_AXI_AWLEN;

            W_state <= W_Trans;
  
          end else
            W_state <= W_Idle;
        end
  
        W_Trans:begin

            if(S_AXI_WVALID &&S_AXI_WREADY)

            case(r_s_axi_awaddr[3:0])
                REG_STATE:begin
                    timer_state <= {S_AXI_WDATA[31:3],(timer_state[2] & (~S_AXI_WDATA[2])),S_AXI_WDATA[1:0]};
                end
                REG_VALUE:begin
                    timer_value <= S_AXI_WDATA;
                end

                default:;
            endcase

            
                r_s_axi_bvalid <= 1'b1;
                W_state <= W_Wait;  
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
        
        r_s_axi_rvalid <= 'd0;
        r_s_axi_rdata <= 'd0;
        r_s_axi_rlast <= 'd0;
    end
  
    else begin

          r_s_axi_rvalid <= 1'b0;
          r_s_axi_rlast <= 1'b0;

          if(S_AXI_ARVALID == 1'b1 && S_AXI_ARVALID == 1'b1) begin
            r_s_axi_araddr <= S_AXI_ARADDR;
            r_s_axi_arlen <= S_AXI_ARLEN;


            R_state <= R_Receive;

            r_s_axi_rvalid <= 1'b1;
            r_s_axi_rlast  <= 1'b1;

            case(S_AXI_ARADDR[3:0])
                REG_STATE:begin
                    r_s_axi_rdata <= timer_state;
                end
                REG_COUNT:begin
                    r_s_axi_rdata <= timer_count;
                end
                REG_VALUE:begin
                    r_s_axi_rdata <= timer_value;
                end

                default:;

            endcase
            
        end
  
  
    
    end
  
  end











endmodule