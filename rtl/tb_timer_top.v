`timescale 1ns/1ps

module tb_timer_top;

    reg         clk;
    reg         rst_n;
    reg  [3:0]  addr;
    reg         wr_en;
    reg         rd_en;
    reg  [31:0] wdata;
    wire [31:0] rdata;
    wire        irq;
    timer_top dut (
        .clk   (clk),
        .rst_n (rst_n),
        .addr  (addr),
        .wr_en (wr_en),
        .rd_en (rd_en),
        .wdata (wdata),
        .rdata (rdata),
        .irq   (irq)
    );
    // 100 MHz clock (10 ns period)
    always #5 clk = ~clk;
    initial begin
        clk   = 0;
        rst_n = 0;
        addr  = 0;
        wr_en = 0;
        rd_en = 0;
        wdata = 0;

        #20;
        rst_n = 1;   // release reset
    end
    task bus_write(input [3:0] a, input [31:0] d);
    begin
        @(posedge clk);
        addr  <= a;
        wdata <= d;
        wr_en <= 1'b1;
        rd_en <= 1'b0;

        @(posedge clk);
        wr_en <= 1'b0;
        addr  <= 0;
        wdata <= 0;
    end
    endtask
    task bus_read(input [3:0] a);
    begin
        @(posedge clk);
        addr  <= a;
        rd_en <= 1'b1;
        wr_en <= 1'b0;

        @(posedge clk);
        rd_en <= 1'b0;
        addr  <= 0;
    end
    endtask
    initial begin
        // wait for reset deassertion
        @(posedge rst_n);

        // LOAD = 10
        bus_write(4'h4, 32'd10);

        // CTRL: enable=1, irq_en=1
        bus_write(4'h0, 32'b11);

        // wait for timer to expire
        repeat (15) @(posedge clk);

        // read STATUS
        bus_read(4'hC);

        // clear interrupt
        bus_write(4'hC, 32'b1);

        #50;
        $finish;
    end

endmodule
