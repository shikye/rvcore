module soc(
    input   wire                    clk,
    input   wire                    rst_n
    );
    
    
    //source 
    //rvcore
    wire                     Rvcore_valid_req_o;
    wire                     Rvcore_rw_o;
    wire             [31:0]  Rvcore_addr_o;
    wire             [127:0] Rvcore_data_o;

    //axi_m

    wire     [127:0]                         axi_data_o; 
    wire                                     axi_rd_over_o;
    wire                                     axi_wr_over_o;

    wire                                    core_WAIT_o;
    wire    [1-1 : 0]                       core_AXI_AWID;
    wire    [32-1 : 0]                      core_AXI_AWADDR;
    wire    [3 : 0]                         core_AXI_AWLEN;
    wire    [2 : 0]                         core_AXI_AWSIZE;
    wire    [1 : 0]                         core_AXI_AWBURST;
    wire                                    core_AXI_AWVALID;
    wire    [32-1 : 0]                      core_AXI_WDATA;
    wire    [32/8-1 : 0]                    core_AXI_WSTRB;
    wire                                    core_AXI_WLAST;
    wire                                    core_AXI_WVALID;
    wire                                    core_AXI_BREADY;
    wire    [1-1 : 0]                       core_AXI_ARID;
    wire    [32-1 : 0]                      core_AXI_ARADDR;
    wire    [3 : 0]                         core_AXI_ARLEN;
    wire    [2 : 0]                         core_AXI_ARSIZE;
    wire    [1 : 0]                         core_AXI_ARBURST;
    wire                                    core_AXI_ARVALID;
    wire                                    core_AXI_RREADY;


    //axi_interconnect 
    wire                                    M0_AWREADY;
    wire                                    M0_WREADY;
    wire  [1-1:0]                           M0_BID;
    wire  [ 1:0]                            M0_BRESP;
    wire                                    M0_BVALID;
    wire                                    M0_ARREADY;
    wire  [1-1:0]                           M0_RID;
    wire  [32-1:0]                          M0_RDATA;
    wire  [ 1:0]                            M0_RRESP;
    wire                                    M0_RLAST;
    wire                                    M0_RVALID;
    wire                                    M1_AWREADY;
    wire                                    M1_WREADY;
    wire  [1-1:0]                           M1_BID;
    wire  [ 1:0]                            M1_BRESP;
    wire                                    M1_BVALID;
    wire                                    M1_ARREADY;
    wire  [1-1:0]                           M1_RID;
    wire  [32-1:0]                          M1_RDATA;
    wire  [ 1:0]                            M1_RRESP;
    wire                                    M1_RLAST;
    wire                                    M1_RVALID;

    wire   [2-1:0]                          S0_AWID;
    wire   [32-1:0]                         S0_AWADDR;
    wire   [ 3:0]                           S0_AWLEN;
    wire   [ 2:0]                           S0_AWSIZE;
    wire   [ 1:0]                           S0_AWBURST;
    wire                                    S0_AWVALID;
    wire   [32-1:0]                         S0_WDATA;
    wire   [4-1:0]                          S0_WSTRB;
    wire                                    S0_WLAST;
    wire                                    S0_WVALID;
    wire                                    S0_BREADY;
    wire   [2-1:0]                          S0_ARID;
    wire   [32-1:0]                         S0_ARADDR;
    wire   [ 3:0]                           S0_ARLEN;
    wire   [ 2:0]                           S0_ARSIZE;
    wire   [ 1:0]                           S0_ARBURST;
    wire                                    S0_ARVALID;
    wire                                    S0_RREADY;
    wire   [2-1:0]                          S1_AWID;
    wire   [32-1:0]                         S1_AWADDR;
    wire   [ 3:0]                           S1_AWLEN;
    wire   [ 2:0]                           S1_AWSIZE;
    wire   [ 1:0]                           S1_AWBURST;
    wire                                    S1_AWVALID;
    wire   [32-1:0]                         S1_WDATA;
    wire   [4-1:0]                          S1_WSTRB;
    wire                                    S1_WLAST;
    wire                                    S1_WVALID;
    wire                                    S1_BREADY;
    wire   [2-1:0]                          S1_ARID;
    wire   [32-1:0]                         S1_ARADDR;
    wire   [ 3:0]                           S1_ARLEN;
    wire   [ 2:0]                           S1_ARSIZE;
    wire   [ 1:0]                           S1_ARBURST;
    wire                                    S1_ARVALID;
    wire                                    S1_RREADY;
    wire   [2-1:0]                          S2_AWID;
    wire   [32-1:0]                         S2_AWADDR;
    wire   [ 3:0]                           S2_AWLEN;
    wire   [ 2:0]                           S2_AWSIZE;
    wire   [ 1:0]                           S2_AWBURST;
    wire                                    S2_AWVALID;
    wire   [32-1:0]                         S2_WDATA;
    wire   [4-1:0]                          S2_WSTRB;
    wire                                    S2_WLAST;
    wire                                    S2_WVALID;
    wire                                    S2_BREADY;
    wire   [2-1:0]                          S2_ARID;
    wire   [32-1:0]                         S2_ARADDR;
    wire   [ 3:0]                           S2_ARLEN;
    wire   [ 2:0]                           S2_ARSIZE;
    wire   [ 1:0]                           S2_ARBURST;
    wire                                    S2_ARVALID;
    wire                                    S2_RREADY;

    wire                                    core_WAIT;

    //axi_rom
    wire                                    rom_AXI_AWREADY;   
    wire                                    rom_AXI_WREADY;    
    wire [2-1 : 0]                          rom_AXI_BID;       
    wire [1 : 0]                            rom_AXI_BRESP;     
    wire                                    rom_AXI_BVALID;    
    wire                                    rom_AXI_ARREADY;   
    wire [2-1 : 0]                          rom_AXI_RID;       
    wire [32-1 : 0]                         rom_AXI_RDATA;     
    wire [1 : 0]                            rom_AXI_RRESP;     
    wire                                    rom_AXI_RLAST;     
    wire                                    rom_AXI_RVALID;    

    //axi_ram
    wire                                    ram_AXI_AWREADY;   
    wire                                    ram_AXI_WREADY;    
    wire [2-1 : 0]                          ram_AXI_BID;       
    wire [1 : 0]                            ram_AXI_BRESP;     
    wire                                    ram_AXI_BVALID;    
    wire                                    ram_AXI_ARREADY;   
    wire [2-1 : 0]                          ram_AXI_RID;       
    wire [32-1 : 0]                         ram_AXI_RDATA;     
    wire [1 : 0]                            ram_AXI_RRESP;     
    wire                                    ram_AXI_RLAST;     
    wire                                    ram_AXI_RVALID;   








    
    rvcore rvcore_ins(
        .clk(clk),
        .rst_n(rst_n),
        .axi_data_i(axi_data_o),  //to axi controller
        .axi_rd_over_i(axi_rd_over_o),
        .axi_wr_over_i(axi_wr_over_o),
        .core_WAIT_i(core_WAIT_o),
        .Rvcore_valid_req_o(Rvcore_valid_req_o),
        .Rvcore_rw_o(Rvcore_rw_o),
        .Rvcore_addr_o(Rvcore_addr_o),
        .Rvcore_data_o(Rvcore_data_o)
    );

    
    axi_m m_interface
    (

        .M_AXI_ACLK(clk),
        .M_AXI_ARESETN(rst_n),
        .Rvcore_valid_req_i(Rvcore_valid_req_o),
        .Rvcore_rw_i(Rvcore_rw_o),
        .Rvcore_addr_i(Rvcore_addr_o),
        .Rvcore_data_i(Rvcore_data_o), 
        .axi_data_o(axi_data_o),  //to axi controller
        .axi_rd_over_o(axi_rd_over_o),
        .axi_wr_over_o(axi_wr_over_o),
        .core_WAIT_i(core_WAIT),
        .core_WAIT_o(core_WAIT_o),
        .M_AXI_AWID(core_AXI_AWID),
        .M_AXI_AWADDR(core_AXI_AWADDR),
        .M_AXI_AWLEN(core_AXI_AWLEN),
        .M_AXI_AWSIZE(core_AXI_AWSIZE),
        .M_AXI_AWBURST(core_AXI_AWBURST),
        .M_AXI_AWVALID(core_AXI_AWVALID),
        .M_AXI_AWREADY(M0_AWREADY),
        .M_AXI_WDATA(core_AXI_WDATA),
        .M_AXI_WSTRB(core_AXI_WSTRB),
        .M_AXI_WLAST(core_AXI_WLAST),
        .M_AXI_WVALID(core_AXI_WVALID),
        .M_AXI_WREADY(M0_WREADY),
        .M_AXI_BID(M0_BID),
        .M_AXI_BRESP(M0_BRESP),
        .M_AXI_BVALID(M0_BVALID),
        .M_AXI_BREADY(core_AXI_BREADY),
        .M_AXI_ARID(core_AXI_ARID),
        .M_AXI_ARADDR(core_AXI_ARADDR),
        .M_AXI_ARLEN(core_AXI_ARLEN),
        .M_AXI_ARSIZE(core_AXI_ARSIZE),
        .M_AXI_ARBURST(core_AXI_ARBURST),
        .M_AXI_ARVALID(core_AXI_ARVALID),
        .M_AXI_ARREADY(M0_ARREADY),
        .M_AXI_RID(M0_RID),
        .M_AXI_RDATA(M0_RDATA),
        .M_AXI_RRESP(M0_RRESP),
        .M_AXI_RLAST(M0_RLAST),
        .M_AXI_RVALID(M0_RVALID),
        .M_AXI_RREADY(core_AXI_RREADY)
);

axi_interconnect ai
(
    .ARESETn(rst_n),
    .ACLK(clk),
    .M0_MID(1'd0),   //多主机情况下，从机分辨主机
    .M0_AWID(core_AXI_AWID),
    .M0_AWADDR(core_AXI_AWADDR),
    .M0_AWLEN(core_AXI_AWLEN),
    .M0_AWSIZE(core_AXI_AWSIZE),
    .M0_AWBURST(core_AXI_AWBURST),
    .M0_AWVALID(core_AXI_AWVALID),
    .M0_AWREADY(M0_AWREADY),
    .M0_WDATA(core_AXI_WDATA),
    .M0_WSTRB(core_AXI_WSTRB),
    .M0_WLAST(core_AXI_WLAST),
    .M0_WVALID(core_AXI_WVALID),
    .M0_WREADY(M0_WREADY),
    .M0_BID(M0_BID),
    .M0_BRESP(M0_BRESP),
    .M0_BVALID(M0_BVALID),
    .M0_BREADY(core_AXI_BREADY),
    .M0_ARID(core_AXI_ARID),
    .M0_ARADDR(core_AXI_ARADDR),
    .M0_ARLEN(core_AXI_ARLEN),
    .M0_ARSIZE(core_AXI_ARSIZE),
    .M0_ARBURST(core_AXI_ARBURST),
    .M0_ARVALID(core_AXI_ARVALID),
    .M0_ARREADY(M0_ARREADY),
    .M0_RID(M0_RID),
    .M0_RDATA(M0_RDATA),
    .M0_RRESP(M0_RRESP),
    .M0_RLAST(M0_RLAST),
    .M0_RVALID(M0_RVALID),
    .M0_RREADY(core_AXI_RREADY),
    .M1_MID(1'd0),   
    .M1_AWID(1'd0),
    .M1_AWADDR(32'd0),
    .M1_AWLEN(4'd0),
    .M1_AWSIZE(3'd0),
    .M1_AWBURST(2'd0),
    .M1_AWVALID(1'd0),
    .M1_AWREADY(M1_AWREADY),
    .M1_WID(1'd0),
    .M1_WDATA(32'd0),
    .M1_WSTRB(4'd0),
    .M1_WLAST(1'd0),
    .M1_WVALID(1'd0),
    .M1_WREADY(M1_WREADY),
    .M1_BID(M1_BID),
    .M1_BRESP(M1_BRESP),
    .M1_BVALID(M1_BVALID),
    .M1_BREADY(1'd0),
    .M1_ARID(1'd0),
    .M1_ARADDR(32'd0),
    .M1_ARLEN(4'd0),
    .M1_ARSIZE(3'd0),
    .M1_ARBURST(2'd0),
    .M1_ARVALID(1'd0),
    .M1_ARREADY(M1_ARREADY),
    .M1_RID(M1_RID),
    .M1_RDATA(M1_RDATA),
    .M1_RRESP(M1_RRESP),
    .M1_RLAST(M1_RLAST),
    .M1_RVALID(M1_RVALID),
    .M1_RREADY(1'd0),

    .S0_AWID(S0_AWID),
    .S0_AWADDR(S0_AWADDR),
    .S0_AWLEN(S0_AWLEN),
    .S0_AWSIZE(S0_AWSIZE),
    .S0_AWBURST(S0_AWBURST),
    .S0_AWVALID(S0_AWVALID),
    .S0_AWREADY(rom_AXI_AWREADY),
    .S0_WDATA(S0_WDATA),
    .S0_WSTRB(S0_WSTRB),
    .S0_WLAST(S0_WLAST),
    .S0_WVALID(S0_WVALID),
    .S0_WREADY(rom_AXI_WREADY),
    .S0_BID(rom_AXI_BID),
    .S0_BRESP(rom_AXI_BRESP),
    .S0_BVALID(rom_AXI_BVALID),
    .S0_BREADY(S0_BREADY),
    .S0_ARID(S0_ARID),
    .S0_ARADDR(S0_ARADDR),
    .S0_ARLEN(S0_ARLEN),
    .S0_ARSIZE(S0_ARSIZE),
    .S0_ARBURST(S0_ARBURST),
    .S0_ARVALID(S0_ARVALID),
    .S0_ARREADY(rom_AXI_ARREADY),
    .S0_RID(rom_AXI_RID),
    .S0_RDATA(rom_AXI_RDATA),
    .S0_RRESP(rom_AXI_RRESP),
    .S0_RLAST(rom_AXI_RLAST),
    .S0_RVALID(rom_AXI_RVALID),
    .S0_RREADY(S0_RREADY),

    .S1_AWID(S1_AWID),
    .S1_AWADDR(S1_AWADDR),
    .S1_AWLEN(S1_AWLEN),
    .S1_AWSIZE(S1_AWSIZE),
    .S1_AWBURST(S1_AWBURST),
    .S1_AWVALID(S1_AWVALID),
    .S1_AWREADY(ram_AXI_AWREADY),
    .S1_WDATA(S1_WDATA),
    .S1_WSTRB(S1_WSTRB),
    .S1_WLAST(S1_WLAST),
    .S1_WVALID(S1_WVALID),
    .S1_WREADY(ram_AXI_WREADY),
    .S1_BID(ram_AXI_BID),
    .S1_BRESP(ram_AXI_BRESP),
    .S1_BVALID(ram_AXI_BVALID),
    .S1_BREADY(S1_BREADY),
    .S1_ARID(S1_ARID),
    .S1_ARADDR(S1_ARADDR),
    .S1_ARLEN(S1_ARLEN),
    .S1_ARSIZE(S1_ARSIZE),
    .S1_ARBURST(S1_ARBURST),
    .S1_ARVALID(S1_ARVALID),
    .S1_ARREADY(ram_AXI_ARREADY),
    .S1_RID(ram_AXI_RID),
    .S1_RDATA(ram_AXI_RDATA),
    .S1_RRESP(ram_AXI_RRESP),
    .S1_RLAST(ram_AXI_RLAST),
    .S1_RVALID(ram_AXI_RVALID),
    .S1_RREADY(S1_RREADY),

    .S2_AWID(S2_AWID),
    .S2_AWADDR(S2_AWADDR),
    .S2_AWLEN(S2_AWLEN),
    .S2_AWSIZE(S2_AWSIZE),
    .S2_AWBURST(S2_AWBURST),
    .S2_AWVALID(S2_AWVALID),
    .S2_AWREADY(1'd0),
    .S2_WDATA(S2_WDATA),
    .S2_WSTRB(S2_WSTRB),
    .S2_WLAST(S2_WLAST),
    .S2_WVALID(S2_WVALID),
    .S2_WREADY(1'd0),
    .S2_BID(2'd0),
    .S2_BRESP(2'd0),
    .S2_BVALID(1'd0),
    .S2_BREADY(S2_BREADY),
    .S2_ARID(S2_ARID),
    .S2_ARADDR(S2_ARADDR),
    .S2_ARLEN(S2_ARLEN),
    .S2_ARSIZE(S2_ARSIZE),
    .S2_ARBURST(S2_ARBURST),
    .S2_ARVALID(S2_ARVALID),
    .S2_ARREADY(1'd0),
    .S2_RID(2'd0),
    .S2_RDATA(32'd0),
    .S2_RRESP(2'd0),
    .S2_RLAST(1'd0),
    .S2_RVALID(1'd0),
    .S2_RREADY(S2_RREADY),
    .core_WAIT(core_WAIT)
);


axi_rom rom
	(
		.S_AXI_ACLK(clk)      ,
		.S_AXI_ARESETN(rst_n)   ,
		.S_AXI_AWID(S0_AWID)      ,
		.S_AXI_AWADDR(S0_AWADDR)    ,
		.S_AXI_AWLEN(S0_AWLEN)     ,
		.S_AXI_AWSIZE(S0_AWSIZE)    ,
		.S_AXI_AWBURST(S0_AWBURST)   ,
		.S_AXI_AWVALID(S0_AWVALID)   ,
		.S_AXI_AWREADY(rom_AXI_AWREADY)   ,
		.S_AXI_WDATA(S0_WDATA)     ,
		.S_AXI_WSTRB(S0_WSTRB)     ,
		.S_AXI_WLAST(S0_WLAST)     ,
		.S_AXI_WVALID(S0_WVALID)    ,
		.S_AXI_WREADY(rom_AXI_WREADY)    ,
		.S_AXI_BID(rom_AXI_BID)       ,
		.S_AXI_BRESP(rom_AXI_BRESP)     ,
		.S_AXI_BVALID(rom_AXI_BVALID)    ,
		.S_AXI_BREADY(S0_BREADY)    ,
		.S_AXI_ARID(S0_ARID)      ,
		.S_AXI_ARADDR(S0_ARADDR)    ,
		.S_AXI_ARLEN(S0_ARLEN)     ,
		.S_AXI_ARSIZE(S0_ARSIZE)    ,
		.S_AXI_ARBURST(S0_ARBURST)   ,
		.S_AXI_ARVALID(S0_ARVALID)   ,
		.S_AXI_ARREADY(rom_AXI_ARREADY)   ,
		.S_AXI_RID(rom_AXI_RID)       ,
		.S_AXI_RDATA(rom_AXI_RDATA)     ,
		.S_AXI_RRESP(rom_AXI_RRESP)     ,
		.S_AXI_RLAST(rom_AXI_RLAST)     ,
		.S_AXI_RVALID(rom_AXI_RVALID)    ,
		.S_AXI_RREADY(S0_RREADY)    
);

axi_ram ram
	(
		.S_AXI_ACLK(clk)      ,
		.S_AXI_ARESETN(rst_n)   ,
		.S_AXI_AWID(S1_AWID)      ,
		.S_AXI_AWADDR(S1_AWADDR)    ,
		.S_AXI_AWLEN(S1_AWLEN)     ,
		.S_AXI_AWSIZE(S1_AWSIZE)    ,
		.S_AXI_AWBURST(S1_AWBURST)   ,
		.S_AXI_AWVALID(S1_AWVALID)   ,
		.S_AXI_AWREADY(ram_AXI_AWREADY)   ,
		.S_AXI_WDATA(S1_WDATA)     ,
		.S_AXI_WSTRB(S1_WSTRB)     ,
		.S_AXI_WLAST(S1_WLAST)     ,
		.S_AXI_WVALID(S1_WVALID)    ,
		.S_AXI_WREADY(ram_AXI_WREADY)    ,
		.S_AXI_BID(ram_AXI_BID)       ,
		.S_AXI_BRESP(ram_AXI_BRESP)     ,
		.S_AXI_BVALID(ram_AXI_BVALID)    ,
		.S_AXI_BREADY(S1_BREADY)    ,
		.S_AXI_ARID(S1_ARID)      ,
		.S_AXI_ARADDR(S1_ARADDR)    ,
		.S_AXI_ARLEN(S1_ARLEN)     ,
		.S_AXI_ARSIZE(S1_ARSIZE)    ,
		.S_AXI_ARBURST(S1_ARBURST)   ,
		.S_AXI_ARVALID(S1_ARVALID)   ,
		.S_AXI_ARREADY(ram_AXI_ARREADY)   ,
		.S_AXI_RID(ram_AXI_RID)       ,
		.S_AXI_RDATA(ram_AXI_RDATA)     ,
		.S_AXI_RRESP(ram_AXI_RRESP)     ,
		.S_AXI_RLAST(ram_AXI_RLAST)     ,
		.S_AXI_RVALID(ram_AXI_RVALID)    ,
		.S_AXI_RREADY(S1_RREADY)    
);


    
    
endmodule
