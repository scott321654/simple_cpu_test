// pc.v - Program Counter module

module program_counter (
    input wire clk,         // Clock
    input wire reset_n,     // Asynchronous active-low reset
    input wire load_en,     // Load enable (for jump/branch instructions)
    input wire [7:0] next_addr_in, // 8-bit address to load when load_en is high
    output reg [7:0] pc_out // Current Program Counter value
);

    // Initial PC value on reset
    initial begin
        pc_out = 8'h00; // Start execution from address 0x00
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pc_out <= 8'h00; // Reset PC to 0
        end else if (load_en) begin
            pc_out <= next_addr_in; // Load new address (for jumps)
        end else begin
            pc_out <= pc_out + 8'h01; // Increment PC for next instruction fetch
        end
    end

endmodule