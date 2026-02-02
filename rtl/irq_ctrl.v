// ------------------------------------------------------------
// Module: irq_ctrl
// Description:
//   Interrupt controller for timer peripheral.
//   Latches an interrupt flag when the timer expires.
//   Supports software clearing of interrupt flag.
//   Interrupt output is masked using interrupt enable signal.
// ------------------------------------------------------------
module irq_ctrl (
    input  wire clk,            // system clock
    input  wire rst_n,            // active-low asynchronous reset

    input  wire timer_expired,   // asserted when timer reaches zero
    input  wire irq_en,           // interrupt enable from CTRL register
    input  wire clr_irq,          // software clear request (W1C behavior)

    output reg  irq_flag,         // latched interrupt status flag
    output wire irq               // interrupt output to CPU
);

    // --------------------------------------------------------
    // IRQ FLAG REGISTER
    // The interrupt flag is set on timer expiration.
    // Software can clear the flag by writing to STATUS register.
    // Clear has higher priority than a new interrupt event.
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Clear interrupt flag on reset
            irq_flag <= 1'b0;
        end else begin
            if (clr_irq) begin
                // Software clears interrupt (highest priority)
                irq_flag <= 1'b0;
            end 
            else if (timer_expired) begin
                // Timer expiration sets interrupt flag
                irq_flag <= 1'b1;
            end
            // Otherwise, hold current interrupt flag state
        end
    end

    // --------------------------------------------------------
    // INTERRUPT OUTPUT LOGIC
    // IRQ is asserted only when interrupt flag is set
    // and interrupt enable is asserted.
    // --------------------------------------------------------
    assign irq = irq_flag & irq_en;

endmodule
