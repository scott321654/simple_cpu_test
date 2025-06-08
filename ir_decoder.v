// ir_decoder.v - Instruction Register and Decoder module

module ir_decoder (
    input wire clk,            // Clock
    input wire reset_n,        // Asynchronous active-low reset
    input wire [15:0] instruction_in, // 16-bit instruction from RAM (Port A)

    // Control signals for PC
    output reg pc_load_en,     // PC load enable
    output wire [7:0] jump_addr, // Jump address (from instruction's operand)

    // Control signals for RAM
    output reg ram_we,         // RAM Write Enable (now for Data Port B)
    // output reg ram_addr_mux_sel, // REMOVED: No longer needed for dual-port RAM

    // Control signals for ALU
    output reg [3:0] alu_opcode, // ALU operation code
    output reg alu_a_mux_sel,   // Mux select for ALU operand A (0: ACC, 1: IR_operand - though A is always ACC in this design)
    output reg alu_b_mux_sel,   // Mux select for ALU operand B (0: Immediate, 1: RAM_data_out_lower8bits)

    // Control signals for Accumulator
    output reg acc_load_en,     // Accumulator load enable

    // Immediate value / Operand from instruction
    output wire [7:0] immediate_operand,

    // Control signal for serial output
    output reg serial_out_en, // Enable for serial output (bit-banging)

    // NEW: Output the decoded opcode for top-level use
    output wire [7:0] decoded_opcode_out // Output decoded opcode
);

    // Internal Instruction Register (IR)
    reg [15:0] ir_reg;

    // Decoded Opcode and Operand (internal wires now connected to outputs)
    assign decoded_opcode_out = ir_reg[15:8]; // High 8 bits are opcode
    assign immediate_operand = ir_reg[7:0]; // Low 8 bits are operand (immediate or address)
    assign jump_addr = ir_reg[7:0]; // Jump address is the operand

    // Define Instruction Opcodes (Crucial: Must match your program.mif and assembler logic)
    parameter OP_NO_OP            = 8'h00; // No operation
    parameter OP_LOAD_ACC_IMM     = 8'h10; // Load immediate into ACC
    parameter OP_LOAD_ACC_MEM     = 8'h11; // Load from memory into ACC
    parameter OP_STORE_ACC_MEM    = 8'h20; // Store ACC into memory
    parameter OP_ADD_ACC_IMM      = 8'h30; // ADD immediate to ACC
    parameter OP_ADD_ACC_MEM      = 8'h31; // ADD from memory to ACC
    parameter OP_SUB_ACC_IMM      = 8'h40; // SUB immediate from ACC
    parameter OP_SUB_ACC_MEM      = 8'h41; // SUB from memory from ACC
    parameter OP_AND_ACC_IMM      = 8'h50; // AND immediate with ACC
    parameter OP_AND_ACC_MEM      = 8'h51; // AND from memory with ACC
    parameter OP_INC_ACC          = 8'h60; // Increment ACC
    parameter OP_JUMP             = 8'h70; // Unconditional Jump
    parameter OP_OUT_ACC_SERIAL   = 8'h80; // Output ACC content via serial

    // ALU OpCodes (must match the alu.v module's parameters)
    parameter ALU_OP_ADD = 4'b0000;
    parameter ALU_OP_SUB = 4'b0001;
    parameter ALU_OP_AND = 4'b0010;
    parameter ALU_OP_INC = 4'b0011;

    // Control signal defaults (combinational logic based on current IR)
    always @(*) begin
        pc_load_en = 1'b0;
        ram_we = 1'b0;                      // Default RAM write enable to 0 (for data port)
        // ram_addr_mux_sel = 1'b0;         // REMOVED
        alu_opcode = 4'b0000;
        alu_a_mux_sel = 1'b0;
        alu_b_mux_sel = 1'b0;
        acc_load_en = 1'b0;
        serial_out_en = 1'b0;

        case (decoded_opcode_out)
            OP_NO_OP: begin
                // No operation
            end

            OP_LOAD_ACC_IMM: begin
                acc_load_en = 1'b1;
            end
            OP_LOAD_ACC_MEM: begin
                acc_load_en = 1'b1;
                // No need to set ram_addr_mux_sel, as data port uses operand address directly
            end
            OP_STORE_ACC_MEM: begin
                ram_we = 1'b1; // Enable write for data port
                // No need to set ram_addr_mux_sel
            end

            OP_ADD_ACC_IMM: begin
                acc_load_en = 1'b1;
                alu_opcode = ALU_OP_ADD;
                alu_b_mux_sel = 1'b0; // Immediate to ALU B
            end
            OP_ADD_ACC_MEM: begin
                acc_load_en = 1'b1;
                alu_opcode = ALU_OP_ADD;
                alu_b_mux_sel = 1'b1; // Data from RAM (Port B) to ALU B
                // No need to set ram_addr_mux_sel
            end
            OP_SUB_ACC_IMM: begin
                acc_load_en = 1'b1;
                alu_opcode = ALU_OP_SUB;
                alu_b_mux_sel = 1'b0;
            end
            OP_SUB_ACC_MEM: begin
                acc_load_en = 1'b1;
                alu_opcode = ALU_OP_SUB;
                alu_b_mux_sel = 1'b1;
                // No need to set ram_addr_mux_sel
            end
            OP_AND_ACC_IMM: begin
                acc_load_en = 1'b1;
                alu_opcode = ALU_OP_AND;
                alu_b_mux_sel = 1'b0;
            end
            OP_AND_ACC_MEM: begin
                acc_load_en = 1'b1;
                alu_opcode = ALU_OP_AND;
                alu_b_mux_sel = 1'b1;
                // No need to set ram_addr_mux_sel
            end

            OP_INC_ACC: begin
                acc_load_en = 1'b1;
                alu_opcode = ALU_OP_INC;
                alu_b_mux_sel = 1'b0;
            end

            OP_JUMP: begin
                pc_load_en = 1'b1;
            end

            OP_OUT_ACC_SERIAL: begin
                serial_out_en = 1'b1;
            end

            default: begin
                // For undefined opcodes, all control signals remain at default (inactive)
            end
        endcase
    end

    // Instruction Register Update (sequential logic)
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ir_reg <= 16'h0000;
        end else begin
            // IR is loaded with the instruction fetched from RAM (instruction_in from Port A)
            ir_reg <= instruction_in;
        end
    end

endmodule