module tb();
reg clk;
reg rst_n;

initial begin
    clk = 1'b0;
    rst_n = 1'b0;
    #100 
    rst_n = 1'b1;
end

always #5 clk = ~clk;


reg                                    Rvcore_valid_req_i;
reg                                    Rvcore_rw_i;
reg    [31:0]                          Rvcore_addr_i;
reg    [127:0]                         Rvcore_data_i; 
wire     [127:0]                         axi_data_o;  //to axi controller
wire                                     axi_rd_over_o;
wire                                     axi_wr_over_o;
wire                                    core_WAIT;
wire    [1-1 : 0]                       M_AXI_AWID;
wire    [32-1 : 0]                      M_AXI_AWADDR;
wire    [3 : 0]                         M_AXI_AWLEN;
wire    [2 : 0]                         M_AXI_AWSIZE;
wire    [1 : 0]                         M_AXI_AWBURST;
wire                                    M_AXI_AWVALID;
wire                                    M_AXI_AWREADY;
wire    [32-1 : 0]                M_AXI_WDATA;
wire    [32/8-1 : 0]              M_AXI_WSTRB;
wire                                    M_AXI_WLAST;
wire                                    M_AXI_WVALID;
wire                                    M_AXI_WREADY;
wire    [1-1 : 0]                M_AXI_BID;
wire    [1 : 0]                         M_AXI_BRESP;
wire                                    M_AXI_BVALID;
wire                                    M_AXI_BREADY;
wire    [1-1 : 0]                M_AXI_ARID;
wire    [32-1 : 0]                M_AXI_ARADDR;
wire    [3 : 0]                         M_AXI_ARLEN;
wire    [2 : 0]                         M_AXI_ARSIZE;
wire    [1 : 0]                         M_AXI_ARBURST;
wire                                    M_AXI_ARVALID;
wire                                    M_AXI_ARREADY;
wire    [1-1 : 0]                M_AXI_RID;
wire    [32-1 : 0]                M_AXI_RDATA;
wire    [1 : 0]                         M_AXI_RRESP;
wire                                    M_AXI_RLAST;
wire                                    M_AXI_RVALID;
wire                                    M_AXI_RREADY;


wire [1 : 0]                        S_AXI_AWID   ;
wire [32-1 : 0]                       S_AXI_AWADDR ;
wire [3 : 0]                          S_AXI_AWLEN  ;
wire [2 : 0]                          S_AXI_AWSIZE ;
wire [1 : 0]                          S_AXI_AWBURST;
wire                                  S_AXI_AWVALID;
 wire                                 S_AXI_AWREADY;
wire [32-1 : 0]                       S_AXI_WDATA  ;
wire [(32/8)-1 : 0]                   S_AXI_WSTRB  ;
wire                                  S_AXI_WLAST  ;
wire                                  S_AXI_WVALID ;
 wire                                 S_AXI_WREADY ;
 wire [1 : 0]                       S_AXI_BID    ;
 wire [1 : 0]                         S_AXI_BRESP  ;
 wire                                 S_AXI_BVALID ;
wire                                  S_AXI_BREADY ;
wire [1 : 0]                        S_AXI_ARID   ;
wire [32-1 : 0]                       S_AXI_ARADDR ;
wire [3 : 0]                          S_AXI_ARLEN  ;
wire [2 : 0]                          S_AXI_ARSIZE ;
wire [1 : 0]                          S_AXI_ARBURST;
wire                                  S_AXI_ARVALID;
 wire                                 S_AXI_ARREADY;
 wire [1 : 0]                       S_AXI_RID    ;
 wire [32-1 : 0]                      S_AXI_RDATA  ;
 wire [1 : 0]                         S_AXI_RRESP  ;
 wire                                 S_AXI_RLAST  ;
 wire                                 S_AXI_RVALID ;
wire                                  S_AXI_RREADY ;


wire r_M1_AWREADY;
wire r_M1_WREADY;
wire r_M1_BID;
wire [1:0] r_M1_BRESP;
wire r_M1_BVALID;
wire r_M1_ARREADY;
wire r_M1_RID;
wire [31:0]  r_M1_RDATA;
wire [1:0]   r_M1_RRESP;
wire r_M1_RLAST;
wire r_M1_RVALID;

wire [1:0] r_S1_AWID;
wire [31:0] r_S1_AWADDR;
wire [3:0] r_S1_AWLEN;
wire [2:0] r_S1_AWSIZE;
wire [1:0] r_S1_AWBURST;
wire r_S1_AWVALID;
wire [31:0] r_S1_WDATA;
wire [3:0] r_S1_WSTRB;
wire r_S1_WLAST;
wire r_S1_WVALID;
wire r_S1_BREADY;
wire [1:0] r_S1_ARID;
wire [31:0] r_S1_ARADDR;
wire [3:0] r_S1_ARLEN;
wire [2:0] r_S1_ARSIZE;
wire [1:0] r_S1_ARBURST;
wire r_S1_ARVALID;
wire r_S1_RREADY;

wire [1:0] r_S2_AWID;
wire [31:0] r_S2_AWADDR;
wire [3:0] r_S2_AWLEN;
wire [2:0] r_S2_AWSIZE;
wire [1:0] r_S2_AWBURST;
wire r_S2_AWVALID;
wire [31:0] r_S2_WDATA;
wire [3:0] r_S2_WSTRB;
wire r_S2_WLAST;
wire r_S2_WVALID;
wire r_S2_BREADY;
wire [1:0] r_S2_ARID;
wire [31:0] r_S2_ARADDR;
wire [3:0] r_S2_ARLEN;
wire [2:0] r_S2_ARSIZE;
wire [1:0] r_S2_ARBURST;
wire r_S2_ARVALID;
wire r_S2_RREADY;


axi_m axi_m_u
(
        .M_AXI_ACLK(clk),
        .M_AXI_ARESETN(rst_n),
        .Rvcore_valid_req_i(Rvcore_valid_req_i),
        .Rvcore_rw_i(Rvcore_rw_i),
        .Rvcore_addr_i(Rvcore_addr_i),
        .Rvcore_data_i(Rvcore_data_i), 
        .axi_data_o(axi_data_o),  //to axi controller
        .axi_rd_over_o(axi_rd_over_o),
        .axi_wr_over_o(axi_wr_over_o),
        .core_WAIT(core_WAIT),
        .M_AXI_AWID(M_AXI_AWID),
        .M_AXI_AWADDR(M_AXI_AWADDR),
        .M_AXI_AWLEN(M_AXI_AWLEN),
        .M_AXI_AWSIZE(M_AXI_AWSIZE),
        .M_AXI_AWBURST(M_AXI_AWBURST),
        .M_AXI_AWVALID(M_AXI_AWVALID),
        .M_AXI_AWREADY(M_AXI_AWREADY),
        .M_AXI_WDATA(M_AXI_WDATA),
        .M_AXI_WSTRB(M_AXI_WSTRB),
        .M_AXI_WLAST(M_AXI_WLAST),
        .M_AXI_WVALID(M_AXI_WVALID),
        .M_AXI_WREADY(M_AXI_WREADY),
        .M_AXI_BID(M_AXI_BID),
        .M_AXI_BRESP(M_AXI_BRESP),
        .M_AXI_BVALID(M_AXI_BVALID),
        .M_AXI_BREADY(M_AXI_BREADY),
        .M_AXI_ARID(M_AXI_ARID),
        .M_AXI_ARADDR(M_AXI_ARADDR),
        .M_AXI_ARLEN(M_AXI_ARLEN),
        .M_AXI_ARSIZE(M_AXI_ARSIZE),
        .M_AXI_ARBURST(M_AXI_ARBURST),
        .M_AXI_ARVALID(M_AXI_ARVALID),
        .M_AXI_ARREADY(M_AXI_ARREADY),
        .M_AXI_RID(M_AXI_RID),
        .M_AXI_RDATA(M_AXI_RDATA),
        .M_AXI_RRESP(M_AXI_RRESP),
        .M_AXI_RLAST(M_AXI_RLAST),
        .M_AXI_RVALID(M_AXI_RVALID),
        .M_AXI_RREADY(M_AXI_RREADY)
);



axi_interconnect inter_u
(
.ARESETn(rst_n),
.ACLK(clk),
.M0_MID(1'b0),   //多主机情况下，从机分辨主机
.M0_AWID(M_AXI_AWID),
.M0_AWADDR(M_AXI_AWADDR),
.M0_AWLEN(M_AXI_AWLEN),
.M0_AWSIZE(M_AXI_AWSIZE),
.M0_AWBURST(M_AXI_AWBURST),
.M0_AWVALID(M_AXI_AWVALID),
.M0_AWREADY(M_AXI_AWREADY),
.M0_WDATA(M_AXI_WDATA),
.M0_WSTRB(M_AXI_WSTRB),
.M0_WLAST(M_AXI_WLAST),
.M0_WVALID(M_AXI_WVALID),
.M0_WREADY(M_AXI_WREADY),
.M0_BID(M_AXI_BID),
.M0_BRESP(M_AXI_BRESP),
.M0_BVALID(M_AXI_BVALID),
.M0_BREADY(M_AXI_BREADY),
.M0_ARID(M_AXI_ARID),
.M0_ARADDR(M_AXI_ARADDR),
.M0_ARLEN(M_AXI_ARLEN),
.M0_ARSIZE(M_AXI_ARSIZE),
.M0_ARBURST(M_AXI_ARBURST),
.M0_ARVALID(M_AXI_ARVALID),
.M0_ARREADY(M_AXI_ARREADY),
.M0_RID(M_AXI_RID),
.M0_RDATA(M_AXI_RDATA),
.M0_RRESP(M_AXI_RRESP),
.M0_RLAST(M_AXI_RLAST),
.M0_RVALID(M_AXI_RVALID),
.M0_RREADY(M_AXI_RREADY),
.M1_MID(1'd1),   
.M1_AWID(1'd0),
.M1_AWADDR(32'd0),
.M1_AWLEN(4'd0),
.M1_AWSIZE(3'd0),
.M1_AWBURST(2'd0),
.M1_AWVALID(1'd0),
.M1_AWREADY(r_M1_AWREADY),
.M1_WID(1'd0),
.M1_WDATA(32'd0),
.M1_WSTRB(4'd0),
.M1_WLAST(1'd0),
.M1_WVALID(1'd0),
.M1_WREADY(r_M1_WREADY),
.M1_BID(r_M1_BID),
.M1_BRESP(r_M1_BRESP),
.M1_BVALID(r_M1_BVALID),
.M1_BREADY(1'd0),
.M1_ARID(1'd0),
.M1_ARADDR(32'd0),
.M1_ARLEN(4'd0),
.M1_ARSIZE(3'd0),
.M1_ARBURST(2'd0),
.M1_ARVALID(1'd0),
.M1_ARREADY(r_M1_ARREADY),
.M1_RID(r_M1_RID),
.M1_RDATA(r_M1_RDATA),
.M1_RRESP(r_M1_RRESP),
.M1_RLAST(r_M1_RLAST),
.M1_RVALID(r_M1_RVALID),
.M1_RREADY(1'd0),
.S0_AWID(S_AXI_AWID),
.S0_AWADDR(S_AXI_AWADDR),
.S0_AWLEN(S_AXI_AWLEN),
.S0_AWSIZE(S_AXI_AWSIZE),
.S0_AWBURST(S_AXI_AWBURST),
.S0_AWVALID(S_AXI_AWVALID),
.S0_AWREADY(S_AXI_AWREADY),
.S0_WDATA(S_AXI_WDATA),
.S0_WSTRB(S_AXI_WSTRB),
.S0_WLAST(S_AXI_WLAST),
.S0_WVALID(S_AXI_WVALID),
.S0_WREADY(S_AXI_WREADY),
.S0_BID(S_AXI_BID),
.S0_BRESP(S_AXI_BRESP),
.S0_BVALID(S_AXI_BVALID),
.S0_BREADY(S_AXI_BREADY),
.S0_ARID(S_AXI_ARID),
.S0_ARADDR(S_AXI_ARADDR),
.S0_ARLEN(S_AXI_ARLEN),
.S0_ARSIZE(S_AXI_ARSIZE),
.S0_ARBURST(S_AXI_ARBURST),
.S0_ARVALID(S_AXI_ARVALID),
.S0_ARREADY(S_AXI_ARREADY),
.S0_RID(S_AXI_RID),
.S0_RDATA(S_AXI_RDATA),
.S0_RRESP(S_AXI_RRESP),
.S0_RLAST(S_AXI_RLAST),
.S0_RVALID(S_AXI_RVALID),
.S0_RREADY(S_AXI_RREADY),
.S1_AWID(r_S1_AWID),
.S1_AWADDR(r_S1_AWADDR),
.S1_AWLEN(r_S1_AWLEN),
.S1_AWSIZE(r_S1_AWSIZE),
.S1_AWBURST(r_S1_AWBURST),
.S1_AWVALID(r_S1_AWVALID),
.S1_AWREADY(1'd0),
.S1_WDATA(r_S1_WDATA),
.S1_WSTRB(r_S1_WSTRB),
.S1_WLAST(r_S1_WLAST),
.S1_WVALID(r_S1_WVALID),
.S1_WREADY(1'd0),
.S1_BID(2'd0),
.S1_BRESP(2'd0),
.S1_BVALID(1'd0),
.S1_BREADY(r_S1_BREADY),
.S1_ARID(r_S1_ARID),
.S1_ARADDR(r_S1_ARADDR),
.S1_ARLEN(r_S1_ARLEN),
.S1_ARSIZE(r_S1_ARSIZE),
.S1_ARBURST(r_S1_ARBURST),
.S1_ARVALID(r_S1_ARVALID),
.S1_ARREADY(1'd0),
.S1_RID(2'd0),
.S1_RDATA(32'd0),
.S1_RRESP(2'd0),
.S1_RLAST(1'd0),
.S1_RVALID(1'd0),
.S1_RREADY(r_S1_RREADY),
.S2_AWID(r_S2_AWID),
.S2_AWADDR(r_S2_AWADDR),
.S2_AWLEN(r_S2_AWLEN),
.S2_AWSIZE(r_S2_AWSIZE),
.S2_AWBURST(r_S2_AWBURST),
.S2_AWVALID(r_S2_AWVALID),
.S2_AWREADY(1'd0),
.S2_WDATA(r_S2_WDATA),
.S2_WSTRB(r_S2_WSTRB),
.S2_WLAST(r_S2_WLAST),
.S2_WVALID(r_S2_WVALID),
.S2_WREADY(1'd0),
.S2_BID(2'd0),
.S2_BRESP(2'd0),
.S2_BVALID(1'd0),
.S2_BREADY(r_S2_BREADY),
.S2_ARID(r_S2_ARID),
.S2_ARADDR(r_S2_ARADDR),
.S2_ARLEN(r_S2_ARLEN),
.S2_ARSIZE(r_S2_ARSIZE),
.S2_ARBURST(r_S2_ARBURST),
.S2_ARVALID(r_S2_ARVALID),
.S2_ARREADY(1'd0),
.S2_RID(2'd0),
.S2_RDATA(32'd0),
.S2_RRESP(2'd0),
.S2_RLAST(1'd0),
.S2_RVALID(1'd0),
.S2_RREADY(r_S2_RREADY),
.core_WAIT(core_WAIT)
);




axi_rom rom_u
	(
.S_AXI_ACLK(clk)      ,
.S_AXI_ARESETN(rst_n)   ,
.S_AXI_AWID(S_AXI_AWID)      ,
.S_AXI_AWADDR(S_AXI_AWADDR)    ,
.S_AXI_AWLEN(S_AXI_AWLEN)     ,
.S_AXI_AWSIZE(S_AXI_AWSIZE)    ,
.S_AXI_AWBURST(S_AXI_AWBURST)   ,
.S_AXI_AWVALID(S_AXI_AWVALID)   ,
.S_AXI_AWREADY(S_AXI_AWREADY)   ,
.S_AXI_WDATA(S_AXI_WDATA)     ,
.S_AXI_WSTRB(S_AXI_WSTRB)     ,
.S_AXI_WLAST(S_AXI_WLAST)     ,
.S_AXI_WVALID(S_AXI_WVALID)    ,
.S_AXI_WREADY(S_AXI_WREADY)    ,
.S_AXI_BID(S_AXI_BID)       ,
.S_AXI_BRESP(S_AXI_BRESP)     ,
.S_AXI_BVALID(S_AXI_BVALID)    ,
.S_AXI_BREADY(S_AXI_BREADY)    ,
.S_AXI_ARID(S_AXI_ARID)      ,
.S_AXI_ARADDR(S_AXI_ARADDR)    ,
.S_AXI_ARLEN(S_AXI_ARLEN)     ,
.S_AXI_ARSIZE(S_AXI_ARSIZE)    ,
.S_AXI_ARBURST(S_AXI_ARBURST)   ,
.S_AXI_ARVALID(S_AXI_ARVALID)   ,
.S_AXI_ARREADY(S_AXI_ARREADY)   ,
.S_AXI_RID(S_AXI_RID)       ,
.S_AXI_RDATA(S_AXI_RDATA)     ,
.S_AXI_RRESP(S_AXI_RRESP)     ,
.S_AXI_RLAST(S_AXI_RLAST)     ,
.S_AXI_RVALID(S_AXI_RVALID)    ,
.S_AXI_RREADY(S_AXI_RREADY)    
);








initial begin
    #100
    Rvcore_valid_req_i = 1'b1;
    Rvcore_rw_i = 1'b0;
    Rvcore_addr_i = 'd0;
    Rvcore_data_i = 128'h03030303030303030303030303030303;
    #10
    Rvcore_valid_req_i = 1'b0;
    #120
    Rvcore_valid_req_i = 1'b1;
    Rvcore_rw_i = 1'b1;
    Rvcore_addr_i = 'd0;
    #12
    Rvcore_valid_req_i = 1'b0;
end

initial begin
    $dumpvars(0,tb
    );
    $dumpfile("tb.vcd");

    #1000000
    $finish;
end

initial begin

    $readmemh("./mem",tb.rom_u.r_ram);
end









endmodule
