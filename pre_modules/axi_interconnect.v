module axi_interconnect
      #(parameter WIDTH_MID   = 1 // Channel ID width in bits
                , WIDTH_ID    = 1 // ID width in bits
                , WIDTH_AD    =32 // address width
                , WIDTH_DA    =32 // data width
                , WIDTH_DS    =(WIDTH_DA/8)  // data strobe width
                , WIDTH_SID   =(WIDTH_MID+WIDTH_ID)// ID for slave 从机用主机ID+事务ID来辨别某一主机事务
                , ADDR_BASE0  =32'h0000_0000 , ADDR_LENGTH0=28  //256MB
                , ADDR_BASE1  =32'h1000_0000 , ADDR_LENGTH1=28 
                , ADDR_BASE2  =32'h2000_0000 , ADDR_LENGTH2=28
       )
(
       input   wire                      ARESETn
     , input   wire                      ACLK
     //--------------------------------------------------------------
     , input   wire  [WIDTH_MID-1:0]     M0_MID   //多主机情况下，从机分辨主机

     , input   wire  [WIDTH_ID-1:0]      M0_AWID
     , input   wire  [WIDTH_AD-1:0]      M0_AWADDR
     , input   wire  [ 3:0]              M0_AWLEN
     , input   wire  [ 2:0]              M0_AWSIZE
     , input   wire  [ 1:0]              M0_AWBURST
     , input   wire                      M0_AWVALID
     , output  wire                      M0_AWREADY
     
     , input   wire  [WIDTH_DA-1:0]      M0_WDATA
     , input   wire  [WIDTH_DS-1:0]      M0_WSTRB
     , input   wire                      M0_WLAST
     , input   wire                      M0_WVALID
     , output  wire                      M0_WREADY
     
     , output  wire  [WIDTH_ID-1:0]      M0_BID
     , output  wire  [ 1:0]              M0_BRESP
     , output  wire                      M0_BVALID
     , input   wire                      M0_BREADY
     
     , input   wire  [WIDTH_ID-1:0]      M0_ARID
     , input   wire  [WIDTH_AD-1:0]      M0_ARADDR
     , input   wire  [ 3:0]              M0_ARLEN
     , input   wire  [ 2:0]              M0_ARSIZE
     , input   wire  [ 1:0]              M0_ARBURST
     , input   wire                      M0_ARVALID
     , output  wire                      M0_ARREADY
     
     , output  wire  [WIDTH_ID-1:0]      M0_RID
     , output  wire  [WIDTH_DA-1:0]      M0_RDATA
     , output  wire  [ 1:0]              M0_RRESP
     , output  wire                      M0_RLAST
     , output  wire                      M0_RVALID
     , input   wire                      M0_RREADY
     //--------------------------------------------------------------
     , input   wire  [WIDTH_MID-1:0]     M1_MID   

     , input   wire  [WIDTH_ID-1:0]      M1_AWID
     , input   wire  [WIDTH_AD-1:0]      M1_AWADDR
     , input   wire  [ 3:0]              M1_AWLEN
     , input   wire  [ 2:0]              M1_AWSIZE
     , input   wire  [ 1:0]              M1_AWBURST
     , input   wire                      M1_AWVALID
     , output  wire                      M1_AWREADY
     
     , input   wire  [WIDTH_ID-1:0]      M1_WID
     , input   wire  [WIDTH_DA-1:0]      M1_WDATA
     , input   wire  [WIDTH_DS-1:0]      M1_WSTRB
     , input   wire                      M1_WLAST
     , input   wire                      M1_WVALID
     , output  wire                      M1_WREADY
     
     , output  wire  [WIDTH_ID-1:0]      M1_BID
     , output  wire  [ 1:0]              M1_BRESP
     , output  wire                      M1_BVALID
     , input   wire                      M1_BREADY
     
     , input   wire  [WIDTH_ID-1:0]      M1_ARID
     , input   wire  [WIDTH_AD-1:0]      M1_ARADDR
     , input   wire  [ 3:0]              M1_ARLEN
     , input   wire  [ 2:0]              M1_ARSIZE
     , input   wire  [ 1:0]              M1_ARBURST
     , input   wire                      M1_ARVALID
     , output  wire                      M1_ARREADY
     
     , output  wire  [WIDTH_ID-1:0]      M1_RID
     , output  wire  [WIDTH_DA-1:0]      M1_RDATA
     , output  wire  [ 1:0]              M1_RRESP
     , output  wire                      M1_RLAST
     , output  wire                      M1_RVALID
     , input   wire                      M1_RREADY
     //--------------------------------------------------------------
     , output  wire   [WIDTH_SID-1:0]    S0_AWID
     , output  wire   [WIDTH_AD-1:0]     S0_AWADDR
     , output  wire   [ 3:0]             S0_AWLEN
     , output  wire   [ 2:0]             S0_AWSIZE
     , output  wire   [ 1:0]             S0_AWBURST
     , output  wire                      S0_AWVALID
     , input   wire                      S0_AWREADY
     
     , output  wire   [WIDTH_DA-1:0]     S0_WDATA
     , output  wire   [WIDTH_DS-1:0]     S0_WSTRB
     , output  wire                      S0_WLAST
     , output  wire                      S0_WVALID
     , input   wire                      S0_WREADY
     
     , input   wire   [WIDTH_SID-1:0]    S0_BID
     , input   wire   [ 1:0]             S0_BRESP
     , input   wire                      S0_BVALID
     , output  wire                      S0_BREADY

     , output  wire   [WIDTH_SID-1:0]    S0_ARID
     , output  wire   [WIDTH_AD-1:0]     S0_ARADDR
     , output  wire   [ 3:0]             S0_ARLEN
     , output  wire   [ 2:0]             S0_ARSIZE
     , output  wire   [ 1:0]             S0_ARBURST
     , output  wire                      S0_ARVALID
     , input   wire                      S0_ARREADY
     
     , input   wire   [WIDTH_SID-1:0]    S0_RID
     , input   wire   [WIDTH_DA-1:0]     S0_RDATA
     , input   wire   [ 1:0]             S0_RRESP
     , input   wire                      S0_RLAST
     , input   wire                      S0_RVALID
     , output  wire                      S0_RREADY
     //--------------------------------------------------------------
     , output  wire   [WIDTH_SID-1:0]    S1_AWID
     , output  wire   [WIDTH_AD-1:0]     S1_AWADDR
     , output  wire   [ 3:0]             S1_AWLEN
     , output  wire   [ 2:0]             S1_AWSIZE
     , output  wire   [ 1:0]             S1_AWBURST
     , output  wire                      S1_AWVALID
     , input   wire                      S1_AWREADY
     
     , output  wire   [WIDTH_DA-1:0]     S1_WDATA
     , output  wire   [WIDTH_DS-1:0]     S1_WSTRB
     , output  wire                      S1_WLAST
     , output  wire                      S1_WVALID
     , input   wire                      S1_WREADY
     
     , input   wire   [WIDTH_SID-1:0]    S1_BID
     , input   wire   [ 1:0]             S1_BRESP
     , input   wire                      S1_BVALID
     , output  wire                      S1_BREADY
     
     , output  wire   [WIDTH_SID-1:0]    S1_ARID
     , output  wire   [WIDTH_AD-1:0]     S1_ARADDR
     , output  wire   [ 3:0]             S1_ARLEN
     , output  wire   [ 2:0]             S1_ARSIZE
     , output  wire   [ 1:0]             S1_ARBURST
     , output  wire                      S1_ARVALID
     , input   wire                      S1_ARREADY
     
     , input   wire   [WIDTH_SID-1:0]    S1_RID
     , input   wire   [WIDTH_DA-1:0]     S1_RDATA
     , input   wire   [ 1:0]             S1_RRESP
     , input   wire                      S1_RLAST
     , input   wire                      S1_RVALID
     , output  wire                      S1_RREADY
     //--------------------------------------------------------------
     , output  wire   [WIDTH_SID-1:0]    S2_AWID
     , output  wire   [WIDTH_AD-1:0]     S2_AWADDR
     , output  wire   [ 3:0]             S2_AWLEN
     , output  wire   [ 2:0]             S2_AWSIZE
     , output  wire   [ 1:0]             S2_AWBURST
     , output  wire                      S2_AWVALID
     , input   wire                      S2_AWREADY
     
     , output  wire   [WIDTH_DA-1:0]     S2_WDATA
     , output  wire   [WIDTH_DS-1:0]     S2_WSTRB
     , output  wire                      S2_WLAST
     , output  wire                      S2_WVALID
     , input   wire                      S2_WREADY
     
     , input   wire   [WIDTH_SID-1:0]    S2_BID
     , input   wire   [ 1:0]             S2_BRESP
     , input   wire                      S2_BVALID
     , output  wire                      S2_BREADY
     


     , output  wire   [WIDTH_SID-1:0]    S2_ARID
     , output  wire   [WIDTH_AD-1:0]     S2_ARADDR
     , output  wire   [ 3:0]             S2_ARLEN
     , output  wire   [ 2:0]             S2_ARSIZE
     , output  wire   [ 1:0]             S2_ARBURST
     , output  wire                      S2_ARVALID
     , input   wire                      S2_ARREADY
     
     , input   wire   [WIDTH_SID-1:0]    S2_RID
     , input   wire   [WIDTH_DA-1:0]     S2_RDATA
     , input   wire   [ 1:0]             S2_RRESP
     , input   wire                      S2_RLAST
     , input   wire                      S2_RVALID
     , output  wire                      S2_RREADY

     //------------to M0
     , output   wire                     core_WAIT
);




//-------------公用总线
wire  [WIDTH_MID-1:0]     MID;   

wire  [WIDTH_ID-1:0]      AWID;
wire  [WIDTH_AD-1:0]      AWADDR;
wire  [ 3:0]              AWLEN;
wire  [ 2:0]              AWSIZE;
wire  [ 1:0]              AWBURST;
wire                      AWVALID;
wire                      AWREADY;

wire  [WIDTH_DA-1:0]      WDATA;
wire  [WIDTH_DS-1:0]      WSTRB;
wire                      WLAST;
wire                      WVALID;
wire                      WREADY;

wire  [WIDTH_ID-1:0]      BID;
wire  [ 1:0]              BRESP;
wire                      BVALID;
wire                      BREADY;

wire  [WIDTH_ID-1:0]      ARID;
wire  [WIDTH_AD-1:0]      ARADDR;
wire  [ 3:0]              ARLEN;
wire  [ 2:0]              ARSIZE;
wire  [ 1:0]              ARBURST;
wire                      ARVALID;
wire                      ARREADY;

wire  [WIDTH_ID-1:0]      RID;
wire  [WIDTH_DA-1:0]      RDATA;
wire  [ 1:0]              RRESP;
wire                      RLAST;
wire                      RVALID;
wire                      RREADY;



//------------总线主机使用仲裁 M1-UART优先

reg M0_USE; 
reg M1_USE;
reg M0_WAIT;

reg r_M0_USE;
reg r_M1_USE;
reg r_M0_WAIT;

assign core_WAIT = M0_WAIT;


always@(*) begin  

        if(ARESETn == 1'b0)begin
            M0_USE = 1'b0;
            M1_USE = 1'b0;
            M0_WAIT = 1'b0;
        end

        if( (!M0_USE) && (!M0_USE) )begin
            if( (M0_ARVALID && M1_ARVALID) || (M0_AWVALID && M1_AWVALID) )begin
                M1_USE = 1'b1;
                M0_WAIT = 1'b1;
            end
            else if(M0_ARVALID || M0_AWVALID)
                M0_USE = 1'b1;
            else if(M1_ARVALID || M1_AWVALID)
                M1_USE = 1'b1;
        end 
end


always@(ACLK or ARESETn)begin
    if(ARESETn == 1'b0)begin
        r_M0_USE <= 1'b0;
        r_M1_USE <= 1'b0;
        r_M0_WAIT <= 1'b0;
    end
    else begin
    
        if(M1_USE && (M0_ARVALID || M0_AWVALID))begin 
            r_M1_USE <= 1'b1;
            M0_WAIT <= 1'b1;
        end 
        if(M1_USE) 
            r_M1_USE <= 1'b1;
        else 
        if(M0_USE) 
            r_M0_USE <= 1'b1;

        if(r_M0_USE)begin
            if(WLAST || RLAST)
                r_M0_USE <= 1'b0;
        end
        else if(r_M1_USE && r_M0_WAIT)begin
            r_M1_USE <= 1'b0;
            r_M0_WAIT <= 1'b0;
        end
        else if(r_M1_USE)begin
            if(WLAST || RLAST)
                r_M1_USE <= 1'b0;
        end
    end


end




//------------从机选择
reg S0_USE;
reg S1_USE;
reg S2_USE;

reg r_S0_USE;
reg r_S1_USE;
reg r_S2_USE;


always@(*) begin  
        
    if(M0_USE && M0_ARVALID) begin
        S0_USE = M0_ARADDR[WIDTH_AD-1:ADDR_LENGTH0] == ADDR_BASE0[WIDTH_AD-1:ADDR_LENGTH0];
        S1_USE = M0_ARADDR[WIDTH_AD-1:ADDR_LENGTH1] == ADDR_BASE1[WIDTH_AD-1:ADDR_LENGTH1];
        S2_USE = M0_ARADDR[WIDTH_AD-1:ADDR_LENGTH2] == ADDR_BASE2[WIDTH_AD-1:ADDR_LENGTH2];
    end
    else if(M1_USE && M1_ARVALID) begin
        S0_USE = M1_ARADDR[WIDTH_AD-1:ADDR_LENGTH0] == ADDR_BASE0[WIDTH_AD-1:ADDR_LENGTH0];
        S1_USE = M1_ARADDR[WIDTH_AD-1:ADDR_LENGTH1] == ADDR_BASE1[WIDTH_AD-1:ADDR_LENGTH1];
        S2_USE = M1_ARADDR[WIDTH_AD-1:ADDR_LENGTH2] == ADDR_BASE2[WIDTH_AD-1:ADDR_LENGTH2];
    end
        
end


always@(ACLK or ARESETn)begin
    if(ARESETn == 1'b0)begin
        r_S0_USE <= 1'b0;
        r_S1_USE <= 1'b0;
        r_S2_USE <= 1'b0;
    end
    else begin
    
        if(S0_USE) 
            r_S0_USE <= 1'b1;
        else if(S1_USE) 
            r_S1_USE <= 1'b1;
        else if(S2_USE)
            r_S2_USE <= 1'b1;
        
    end
end





//----------------------Router
//原本应该以不同通道来做router，但为了简便，一致route所有通道
assign MID = (M0_USE || r_M0_USE) ? 1'b0 : 1'b1;

assign AWID = (M0_USE || r_M0_USE) ? M0_AWID : (M1_USE || r_M1_USE) ? M1_AWID : 'd0;
assign AWADDR = (M0_USE || r_M0_USE) ? M0_AWADDR : (M1_USE || r_M1_USE) ? M1_AWADDR : 'd0;
assign AWLEN = (M0_USE || r_M0_USE) ? M0_AWLEN : (M1_USE || r_M1_USE) ? M1_AWLEN : 'd0;
assign AWSIZE = (M0_USE || r_M0_USE) ? M0_AWSIZE : (M1_USE || r_M1_USE) ? M1_AWSIZE : 'd0;
assign AWBURST = (M0_USE || r_M0_USE) ? M0_AWBURST : (M1_USE || r_M1_USE) ? M1_AWBURST : 'd0;
assign AWVALID = (M0_USE || r_M0_USE) ? M0_AWVALID : (M1_USE || r_M1_USE) ? M1_AWVALID : 'd0;
assign AWREADY = (S0_USE || r_S0_USE) ? S0_AWREADY : (S1_USE || r_S1_USE) ? S1_AWREADY : (S2_USE || r_S2_USE) ? S2_AWREADY : 'd0;

assign WDATA = (M0_USE || r_M0_USE) ? M0_WDATA : (M1_USE || r_M1_USE) ? M1_WDATA : 'd0;
assign WSTRB = (M0_USE || r_M0_USE) ? M0_WSTRB : (M1_USE || r_M1_USE) ? M1_WSTRB : 'd0;
assign WLAST = (M0_USE || r_M0_USE) ? M0_WLAST : (M1_USE || r_M1_USE) ? M1_WLAST : 'd0;
assign WVALID = (M0_USE || r_M0_USE) ? M0_WVALID : (M1_USE || r_M1_USE) ? M1_WVALID : 'd0;
assign WREADY = (S0_USE || r_S0_USE) ? S0_WREADY : (S1_USE || r_S1_USE) ? S1_WREADY : (S2_USE || r_S2_USE) ? S2_WREADY : 'd0;

assign BID = (S0_USE || r_S0_USE) ? S0_BID : (S1_USE || r_S1_USE) ? S1_BID : (S2_USE || r_S2_USE) ? S2_BID : 'd0;
assign BRESP = (S0_USE || r_S0_USE) ? S0_BRESP : (S1_USE || r_S1_USE) ? S1_BRESP : (S2_USE || r_S2_USE) ? S2_BRESP : 'd0;
assign BVALID = (S0_USE || r_S0_USE) ? S0_BVALID : (S1_USE || r_S1_USE) ? S1_BVALID : (S2_USE || r_S2_USE) ? S2_BVALID : 'd0;
assign BREADY = (M0_USE || r_M0_USE) ? M0_BREADY : (M1_USE || r_M1_USE) ? M1_BREADY : 'd0;

assign ARID = (M0_USE || r_M0_USE) ? M0_ARID : (M1_USE || r_M1_USE) ? M1_ARID : 'd0;
assign ARADDR = (M0_USE || r_M0_USE) ? M0_ARADDR : (M1_USE || r_M1_USE) ? M1_ARADDR : 'd0;
assign ARLEN = (M0_USE || r_M0_USE) ? M0_ARLEN : (M1_USE || r_M1_USE) ? M1_ARLEN : 'd0;
assign ARSIZE = (M0_USE || r_M0_USE) ? M0_ARSIZE : (M1_USE || r_M1_USE) ? M1_ARSIZE : 'd0;
assign ARBURST = (M0_USE || r_M0_USE) ? M0_ARBURST : (M1_USE || r_M1_USE) ? M1_ARBURST : 'd0;
assign ARVALID = (M0_USE || r_M0_USE) ? M0_ARVALID : (M1_USE || r_M1_USE) ? M1_ARVALID : 'd0;
assign ARREADY = (S0_USE || r_S0_USE) ? S0_ARREADY : (S1_USE || r_S1_USE) ? S1_ARREADY : (S2_USE || r_S2_USE) ? S2_ARREADY : 'd0;

assign RID = (M0_USE || r_M0_USE) ? M0_RID : (M1_USE || r_M1_USE) ? M1_RID : 'd0;
assign RDATA = (S0_USE || r_S0_USE) ? S0_RDATA : (S1_USE || r_S1_USE) ? S1_RDATA : (S2_USE || r_S2_USE) ? S2_RDATA : 'd0;
assign RRESP = (S0_USE || r_S0_USE) ? S0_RRESP : (S1_USE || r_S1_USE) ? S1_RRESP : (S2_USE || r_S2_USE) ? S2_RRESP : 'd0;
assign RLAST = (S0_USE || r_S0_USE) ? S0_RLAST : (S1_USE || r_S1_USE) ? S1_RLAST : (S2_USE || r_S2_USE) ? S2_RLAST : 'd0;
assign RVALID = (S0_USE || r_S0_USE) ? S0_RVALID : (S1_USE || r_S1_USE) ? S1_RVALID : (S2_USE || r_S2_USE) ? S2_RVALID : 'd0;
assign RREADY = (M0_USE || r_M0_USE) ? M0_RREADY : (M1_USE || r_M1_USE) ? M1_RREADY : 'd0;


//---------------output 
assign M0_AWREADY = (M0_USE || r_M0_USE) ? AWREADY : 'd0;
assign M0_WREADY = (M0_USE || r_M0_USE) ? WREADY : 'd0;
assign M0_BID = (M0_USE || r_M0_USE) ? BID : 'd0;
assign M0_BRESP = (M0_USE || r_M0_USE) ? BRESP : 'd0;
assign M0_BVALID = (M0_USE || r_M0_USE) ? BVALID : 'd0;
assign M0_ARREADY = (M0_USE || r_M0_USE) ? ARREADY : 'd0;
assign M0_RID = (M0_USE || r_M0_USE) ? RID : 'd0;
assign M0_RDATA = (M0_USE || r_M0_USE) ? RDATA : 'd0;
assign M0_RRESP = (M0_USE || r_M0_USE) ? RRESP : 'd0;
assign M0_RLAST = (M0_USE || r_M0_USE) ? RLAST : 'd0;
assign M0_RVALID = (M0_USE || r_M0_USE) ? RVALID : 'd0;

assign M1_AWREADY = (M1_USE || r_M1_USE) ? AWREADY : 'd0;
assign M1_WREADY = (M1_USE || r_M1_USE) ? WREADY : 'd0;
assign M1_BID = (M1_USE || r_M1_USE) ? BID : 'd0;
assign M1_BRESP = (M1_USE || r_M1_USE) ? BRESP : 'd0;
assign M1_BVALID = (M1_USE || r_M1_USE) ? BVALID : 'd0;
assign M1_ARREADY = (M1_USE || r_M1_USE) ? ARREADY : 'd0;
assign M1_RID = (M1_USE || r_M1_USE) ? RID : 'd0;
assign M1_RDATA = (M1_USE || r_M1_USE) ? RDATA : 'd0;
assign M1_RRESP = (M1_USE || r_M1_USE) ? RRESP : 'd0;
assign M1_RLAST = (M1_USE || r_M1_USE) ? RLAST : 'd0;
assign M1_RVALID = (M1_USE || r_M1_USE) ? RVALID : 'd0;



assign S0_AWID = (S0_USE || r_S0_USE) ? {MID, AWID} : 'd0;
assign S0_AWADDR = (S0_USE || r_S0_USE) ? AWADDR : 'd0;
assign S0_AWLEN = (S0_USE || r_S0_USE) ? AWLEN : 'd0;
assign S0_AWSIZE = (S0_USE || r_S0_USE) ? AWSIZE : 'd0;
assign S0_AWBURST = (S0_USE || r_S0_USE) ? AWBURST : 'd0;
assign S0_AWVALID = (S0_USE || r_S0_USE) ? AWVALID : 'd0;
assign S0_WDATA = (S0_USE || r_S0_USE) ? WDATA : 'd0;
assign S0_WSTRB = (S0_USE || r_S0_USE) ? WSTRB : 'd0;
assign S0_WLAST = (S0_USE || r_S0_USE) ? WLAST : 'd0;
assign S0_WVALID = (S0_USE || r_S0_USE) ? WVALID : 'd0;
assign S0_BREADY = (S0_USE || r_S0_USE) ? BREADY : 'd0;
assign S0_ARID = (S0_USE || r_S0_USE) ? {MID, ARID} : 'd0;
assign S0_ARADDR = (S0_USE || r_S0_USE) ? ARADDR : 'd0;
assign S0_ARLEN = (S0_USE || r_S0_USE) ? ARLEN : 'd0;
assign S0_ARSIZE = (S0_USE || r_S0_USE) ? ARSIZE : 'd0;
assign S0_ARBURST = (S0_USE || r_S0_USE) ? ARBURST : 'd0;
assign S0_ARVALID = (S0_USE || r_S0_USE) ? ARVALID : 'd0;
assign S0_RREADY = (S0_USE || r_S0_USE) ? RREADY : 'd0;

assign S1_AWID = (S1_USE || r_S1_USE) ? {MID, AWID} : 'd0;
assign S1_AWADDR = (S1_USE || r_S1_USE) ? AWADDR : 'd0;
assign S1_AWLEN = (S1_USE || r_S1_USE) ? AWLEN : 'd0;
assign S1_AWSIZE = (S1_USE || r_S1_USE) ? AWSIZE : 'd0;
assign S1_AWBURST = (S1_USE || r_S1_USE) ? AWBURST : 'd0;
assign S1_AWVALID = (S1_USE || r_S1_USE) ? AWVALID : 'd0;
assign S1_WDATA = (S1_USE || r_S1_USE) ? WDATA : 'd0;
assign S1_WSTRB = (S1_USE || r_S1_USE) ? WSTRB : 'd0;
assign S1_WLAST = (S1_USE || r_S1_USE) ? WLAST : 'd0;
assign S1_WVALID = (S1_USE || r_S1_USE) ? WVALID : 'd0;
assign S1_BREADY = (S1_USE || r_S1_USE) ? BREADY : 'd0;
assign S1_ARID = (S1_USE || r_S1_USE) ? {MID, ARID} : 'd0;
assign S1_ARADDR = (S1_USE || r_S1_USE) ? ARADDR : 'd0;
assign S1_ARLEN = (S1_USE || r_S1_USE) ? ARLEN : 'd0;
assign S1_ARSIZE = (S1_USE || r_S1_USE) ? ARSIZE : 'd0;
assign S1_ARBURST = (S1_USE || r_S1_USE) ? ARBURST : 'd0;
assign S1_ARVALID = (S1_USE || r_S1_USE) ? ARVALID : 'd0;
assign S1_RREADY = (S1_USE || r_S1_USE) ? RREADY : 'd0;

assign S2_AWID = (S2_USE || r_S2_USE) ? {MID, AWID} : 'd0;
assign S2_AWADDR = (S2_USE || r_S2_USE) ? AWADDR : 'd0;
assign S2_AWLEN = (S2_USE || r_S2_USE) ? AWLEN : 'd0;
assign S2_AWSIZE = (S2_USE || r_S2_USE) ? AWSIZE : 'd0;
assign S2_AWBURST = (S2_USE || r_S2_USE) ? AWBURST : 'd0;
assign S2_AWVALID = (S2_USE || r_S2_USE) ? AWVALID : 'd0;
assign S2_WDATA = (S2_USE || r_S2_USE) ? WDATA : 'd0;
assign S2_WSTRB = (S2_USE || r_S2_USE) ? WSTRB : 'd0;
assign S2_WLAST = (S2_USE || r_S2_USE) ? WLAST : 'd0;
assign S2_WVALID = (S2_USE || r_S2_USE) ? WVALID : 'd0;
assign S2_BREADY = (S2_USE || r_S2_USE) ? BREADY : 'd0;
assign S2_ARID = (S2_USE || r_S2_USE) ? {MID, ARID} : 'd0;
assign S2_ARADDR = (S2_USE || r_S2_USE) ? ARADDR : 'd0;
assign S2_ARLEN = (S2_USE || r_S2_USE) ? ARLEN : 'd0;
assign S2_ARSIZE = (S2_USE || r_S2_USE) ? ARSIZE : 'd0;
assign S2_ARBURST = (S2_USE || r_S2_USE) ? ARBURST : 'd0;
assign S2_ARVALID = (S2_USE || r_S2_USE) ? ARVALID : 'd0;
assign S2_RREADY = (S2_USE || r_S2_USE) ? RREADY : 'd0;



endmodule