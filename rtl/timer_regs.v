// ------------------------------------------------------------
// Module: timer_regs
// Description:
//   Memory-mapped register block for timer peripheral.
//   Implements CTRL, LOAD, COUNT (read-only), and STATUS registers.
//   Provides control signals to timer and interrupt logic.
// ------------------------------------------------------------
module timer_regs (
    input  wire        clk,        // system clock
    input  wire        rst_n,          // active-low asynchronous reset

    // Simple bus interface
    input  wire [3:0]  addr,          // register address
    input  wire        wr_en,          // write enable
    input  wire        rd_en,          // read enable
    input  wire [31:0] wdata,          // write data

    // Input from timer counter
    input  wire [31:0] count_in,       // current timer count value

    // Read data back to bus
    output reg  [31:0] rdata,          

    // Control outputs
    output reg         enable,          // timer enable
    output reg         irq_en,           // interrupt enable
    output reg  [31:0] load,             // timer reload value
    output reg         irq_flag          // interrupt status flag
);

    // --------------------------------------------------------
    // WRITE LOGIC
    // Registers are written on rising clock edge when wr_en is asserted.
    // Reset clears all registers to known values.
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all control and status registers
            enable   <= 1'b0;
            irq_en   <= 1'b0;
            load     <= 32'd0;
            irq_flag <= 1'b0;
        end 
        else if (wr_en) begin
            case (addr)
                // CTRL register (0x0)
                // bit[0] : timer enable
                // bit[1] : interrupt enable
                4'h0: begin
                    enable <= wdata[0];
                    irq_en <= wdata[1];
                end

                // LOAD register (0x4)
                // Full 32-bit reload value for timer
                4'h4: begin
                    load <= wdata;
                end

                // STATUS register (0xC)
                // bit[0] : interrupt flag (W1C handled at top level)
                4'hC: begin
                    irq_flag <= wdata[0];
                end

                // Undefined addresses: no operation
                default: ;
            endcase
        end
    end

    // --------------------------------------------------------
    // READ LOGIC (COMBINATIONAL)
    // Places selected register value on rdata when rd_en is asserted.
    // --------------------------------------------------------
    always @(*) begin
        rdata = 32'd0;  // default value
        if (rd_en) begin
            case (addr)
                // CTRL register readback
                4'h0: rdata = {30'd0, irq_en, enable};

                // LOAD register readback
                4'h4: rdata = load;

                // COUNT register readback (read-only)
                4'h8: rdata = count_in;

                // STATUS register readback
                4'hC: rdata = {31'd0, irq_flag};

                default: rdata = 32'd0;
            endcase
        end
    end

endmodule
