module tb;

    reg     clk;
    reg     rst_n;

    always #10 clk = ~clk;

    initial begin
        clk <= 1'b0;
        rst_n <= 1'b0;

        #30 
        rst_n <= 1'b1;
    end

    initial begin
        // $readmemh("./inst1",tb.soc_ins.rom.r_ram);
        // $readmemh("./inst2",tb.soc_ins.rom.r_ram,4096);
        // $readmemh("./inst3",tb.soc_ins.rom.r_ram,4160);
        $readmemh("./inst",tb.soc_ins.rom.r_ram);
    end


    initial begin
        $dumpvars(0,tb.soc_ins
        ,tb.soc_ins.rvcore_ins.Dcache_ins.Dcache_Data_Block[0]
        );
        $dumpfile("tb.vcd");
    end


    initial begin

        wait(tb.soc_ins.rvcore_ins.regs_ins.regs[26] == 32'd1) begin
            #1000
            if(tb.soc_ins.rvcore_ins.regs_ins.regs[27] == 32'd1) begin
                $display("PASS");
                $display("t3 = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[28]);
            end
            else begin
                $display("FAIL");
                $display("ra = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[1]);
                $display("t4 = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[29]);
                $display("t5 = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[30]);
                $display("gp = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[3]);
            end
            $finish;
        end


    end

    always@(posedge clk) begin
        $display($time);
        $display("ra = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[1]);
        $display("sp = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[2]);
        $display("a0 = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[10]);
        $display("t4 = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[29]);
        $display("t5 = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[30]);
        $display("gp = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[3]);
        // $display("t1 = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[6]);
        // $display("t2 = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[7]);
        // $display("t3 = 0x%x",tb.soc_ins.rvcore_ins.regs_ins.regs[28]);
        // $display("--------------------------------------------------");
    end


    initial begin
        #100000
        $display("timeout");
        $finish;
    end



    soc soc_ins(
        .clk(clk),
        .rst_n(rst_n)
    );


endmodule
