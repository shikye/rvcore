//      start|Data|Stop
//bits    1     8    1
//level   0     x    1
//data低位优先

module uart#                 //外设的访问不经过Cache   只提供写功能
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


        //
        input   wire                                rx_pin,
        output  wire                                tx_pin
);

    localparam BAUD_115200 = 32'h1B8;



    localparam REG_STATE = 8'h0;
    localparam REG_TX = 8'h4;
    localparam REG_BAUD = 8'h8;



    //control regs

    //[0], tx_using --- 1--using, 0--idle  ro
    reg [31:0]  uart_state;


    reg [31:0]  uart_tx;


    reg [31:0]  uart_baud;



/**********************FSM************************/
//对主机状态
    reg [1:0]                           W_state;

    localparam  W_Idle  = 0;
    localparam  W_Trans = 1;
    localparam  W_Wait  = 2;
    
    
    reg [1:0]                           R_state;
    
    localparam  R_Idle  = 0;
    localparam  R_Receive   = 1;


    reg [1:0]                           TX_state;

    localparam TX_Idle = 0;
    localparam TX_Start = 1;
    localparam TX_Send = 2;
    localparam TX_Stop = 3;
    
    /**********************reg_def*************************/
    reg [WIDTH_AD-1 : 0]            r_s_axi_awaddr                          ;
    reg [7 : 0]                     r_s_axi_awlen                           ;
    
    reg [WIDTH_AD-1 : 0]            r_s_axi_araddr                          ;
    reg [7 : 0]                     r_s_axi_arlen                           ;
    
    reg                             r_s_axi_rvalid                          ;
    reg  [31:0]                     r_s_axi_rdata                           ;
    reg                             r_s_axi_rlast                           ;
    
    reg                             r_s_axi_bvalid                          ;


    reg                             tx_reg;
    reg                             tx_valid_req;
    
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

    assign              tx_pin          = tx_reg                            ;





    /*Write Transaction*/
always @(posedge S_AXI_ACLK) begin
    if(S_AXI_ARESETN == 1'b0) begin
      W_state <= W_Idle;
  
      r_s_axi_awaddr <= 32'd0;
      r_s_axi_awlen <= 'd0;
      r_s_axi_bvalid <= 1'b0;

      uart_tx <= 32'd0;
      uart_baud <= BAUD_115200;

      tx_valid_req <= 1'b0;
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

            if(S_AXI_WVALID &&S_AXI_WREADY)begin

            case(r_s_axi_awaddr[7:0])
                REG_TX:begin
                    if(uart_state[0] == 1'b0)begin
                        uart_tx <= S_AXI_WDATA;
                        tx_valid_req <= 1'b1;
                    end
                end
                REG_BAUD:begin
                    uart_baud <= S_AXI_WDATA;
                end

                default:;
            endcase

            
                r_s_axi_bvalid <= 1'b1;
                W_state <= W_Wait;  
            end
        end
  
        W_Wait:begin

            tx_valid_req <= 1'b0;

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

            case(S_AXI_ARADDR[7:0])
                REG_STATE:begin
                    r_s_axi_rdata <= uart_state;
                end
                REG_TX:begin
                    r_s_axi_rdata <= uart_tx;
                end
                REG_BAUD:begin
                    r_s_axi_rdata <= uart_baud;
                end

                default:;

            endcase
            
        end
  
  
    
    end
  
  end




//-----------------------------------------------TX
reg [15:0]                 cycle_cnt;
reg [3:0]                  bit_cnt;




always@(posedge S_AXI_ACLK)begin
    if(S_AXI_ARESETN == 1'b0)begin
        uart_state <= 32'd0;

        TX_state <= TX_Idle;
        cycle_cnt <= 16'd0;
        bit_cnt <= 4'd0;
        tx_reg <= 1'b0;
    end
    else begin
        if(TX_state == TX_Idle)begin
            tx_reg <= 1'b1;
            if(tx_valid_req)begin
                uart_state[0] <= 1'b1;  //using

                TX_state <= TX_Start;
                cycle_cnt <= 16'd0;
                bit_cnt <= 4'd0;
                tx_reg <= 1'b0;
            end
        end
        else begin
            cycle_cnt <= cycle_cnt + 16'd1;

            if(cycle_cnt == uart_baud[15:0])begin
                cycle_cnt <= 16'd0;
            

                case(TX_state)
                    TX_Start:begin
                        tx_reg <= uart_tx[bit_cnt];
                        bit_cnt <= bit_cnt + 4'd1;
                        TX_state <= TX_Send;
                    end
                    TX_Send:begin
                        bit_cnt <= bit_cnt + 4'd1;
                        if(bit_cnt == 4'd8)begin
                            TX_state <= TX_Stop;
                            tx_reg <= 1'b1; //停止位
                        end
                        else 
                            tx_reg <= uart_tx[bit_cnt];
                    end
                    TX_Stop:begin
                        TX_state <= TX_Idle;

                        uart_state[0] <= 1'b0;
                    
                    end
                
            
                    default:;
                endcase
            
            end
        
        
        end
    
    
    end



end






endmodule