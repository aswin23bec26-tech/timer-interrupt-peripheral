// ------------------------------------------------------------
// Module: timer_counter
// Description:
//   Down-counting timer module with automatic reload.
//   The counter decrements on each clock when enabled.
//   When the count reaches zero, it reloads from the LOAD value.
//   The timer is disabled when LOAD = 0 to avoid continuous interrupts.
// ------------------------------------------------------------
module timer_counter (
    input  wire        clk,        // system clock
    input  wire        rst_n,          // active-low asynchronous reset
    input  wire        enable,         // timer enable from CTRL register
    input  wire [31:0] load,           // reload value from LOAD register
    output reg  [31:0] count           // current timer count value
);

    // --------------------------------------------------------
    // TIMER COUNT LOGIC
    // Counter updates on rising clock edge.
    // Reset forces counter to zero.
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Initialize counter on reset
            count <= 32'd0;
        end 
        else if (enable && load != 32'd0) begin
            // Timer runs only when enabled and load value is valid
            if (count == 32'd0) begin
                // Reload counter when terminal count is reached
                count <= load;
            end 
            else begin
                // Decrement counter on each clock cycle
                count <= count - 32'd1;
            end
        end
        // If enable is low or load is zero, counter holds its value
    end

endmodule
