// ------------------------------------------------------------
// Module: timer_top
// Description:
//   Top-level integration module for memory-mapped timer peripheral.
//   Connects register file, timer counter, and interrupt controller.
//   Provides a simple bus interface and interrupt output.
// ------------------------------------------------------------
module timer_top (
    input  wire        clk,        // system clock
    input  wire        rst_n,          // active-low asynchronous reset

    // Simple bus interface
    input  wire [3:0]  addr,          // register address
    input  wire        wr_en,          // write enable
    input  wire        rd_en,          // read enable
    input  wire [31:0] wdata,          // write data
    output wire [31:0] rdata,          // read data

    // Interrupt output
    output wire        irq             // interrupt request to CPU
);

    // --------------------------------------------------------
    // INTERNAL SIGNALS
    // --------------------------------------------------------
    wire        enable;                // timer enable
    wire        irq_en;                 // interrupt enable
    wire [31:0] load;                   // timer reload value
    wire [31:0] count;                  // current timer count
    wire        irq_flag;               // latched interrupt flag

    wire        timer_expired;          // timer expiration event
    wire        clr_irq;                // interrupt clear request

    // --------------------------------------------------------
    // TIMER EXPIRATION DETECTION
    // Asserted when counter reaches zero while timer is enabled
    // --------------------------------------------------------
    assign timer_expired = (count == 32'd0) && enable;

    // --------------------------------------------------------
    // INTERRUPT CLEAR LOGIC (W1C)
    // Software clears interrupt by writing '1' to STATUS[0]
    // --------------------------------------------------------
    assign clr_irq = wr_en && (addr == 4'hC) && wdata[0];

    // --------------------------------------------------------
    // REGISTER FILE INSTANCE
    // Provides control and status registers
    // --------------------------------------------------------
    timer_regs u_regs (
        .clk      (clk),
        .rst_n    (rst_n),
        .addr     (addr),
        .wr_en    (wr_en),
        .rd_en    (rd_en),
        .wdata    (wdata),
        .count_in (count),
        .rdata    (rdata),
        .enable   (enable),
        .irq_en   (irq_en),
        .load     (load),
        .irq_flag (irq_flag)
    );

    // --------------------------------------------------------
    // TIMER COUNTER INSTANCE
    // Generates the down-counting timer value
    // --------------------------------------------------------
    timer_counter u_counter (
        .clk    (clk),
        .rst_n  (rst_n),
        .enable (enable),
        .load   (load),
        .count  (count)
    );

    // --------------------------------------------------------
    // INTERRUPT CONTROLLER INSTANCE
    // Latches interrupt flag and generates IRQ output
    // --------------------------------------------------------
    irq_ctrl u_irq (
        .clk           (clk),
        .rst_n         (rst_n),
        .timer_expired (timer_expired),
        .irq_en        (irq_en),
        .clr_irq       (clr_irq),
        .irq_flag      (irq_flag),
        .irq           (irq)
    );

endmodule
