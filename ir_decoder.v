// ir_decoder.v - Instruction Register and Decoder module

module ir_decoder (
    input wire clk,            // Clock
    input wire reset_n,        // Asynchronous active-low reset
    input wire [15:0] instruction_in, // 16-bit instruction from RAM (Port A)

    
    output reg pc_load_en,     
    output wire [7:0] jump_addr,
    output reg ram_we, 
    output reg [3:0] alu_opcode, // ALU operation code
    output reg alu_a_mux_sel,   
    output reg alu_b_mux_sel,  
    output reg acc_load_en,     // Accumulator load enable

    output wire [7:0] immediate_operand,

    output reg serial_out_en, // Enable for serial output (bit-banging)

    output wire [7:0] decoded_opcode_out // Output decoded opcode
);

    reg [15:0] ir_reg;

    assign decoded_opcode_out = ir_reg[15:8]; // High 8 bits are opcode
    assign immediate_operand = ir_reg[7:0]; // Low 8 bits are operand 
    assign jump_addr = ir_reg[7:0];            // Jump address is the operand

    parameter OP_NO_OP = 8'h00; 				// No operation
    parameter OP_LOAD_ACC_IMM = 8'h10; 	// Load immediate into ACC
    parameter OP_LOAD_ACC_MEM = 8'h11; 	// Load from memory into ACC
    parameter OP_STORE_ACC_MEM = 8'h20; 	// Store ACC into memory
    parameter OP_ADD_ACC_IMM = 8'h30; 		// ADD immediate to ACC
    parameter OP_ADD_ACC_MEM = 8'h31; 		// ADD from memory to ACC
    parameter OP_SUB_ACC_IMM  = 8'h40; 	// SUB immediate from ACC
    parameter OP_SUB_ACC_MEM = 8'h41; 		// SUB from memory from ACC
    parameter OP_AND_ACC_IMM = 8'h50; 		// AND immediate with ACC
    parameter OP_AND_ACC_MEM = 8'h51; 		// AND from memory with ACC
    parameter OP_INC_ACC = 8'h60;         // Increment ACC
    parameter OP_JUMP = 8'h70;    			// Unconditional Jump
    parameter OP_OUT_ACC_SERIAL = 8'h80;  // Output ACC content via serial

    parameter ALU_OP_ADD = 4'b0000;
    parameter ALU_OP_SUB = 4'b0001;
    parameter ALU_OP_AND = 4'b0010;
    parameter ALU_OP_INC = 4'b0011;

    always @(*) begin
        pc_load_en = 1'b0;
        ram_we = 1'b0;                      
        // ram_addr_mux_sel = 1'b0;         // I REMOVED IT
        alu_opcode = 4'b0000;
        alu_a_mux_sel = 1'b0;
        alu_b_mux_sel = 1'b0;
        acc_load_en = 1'b0;
        serial_out_en = 1'b0;

        case (decoded_opcode_out)
            OP_NO_OP: begin
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
                // ram_addr_mux_sel = 1'b1;
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
                // ram_addr_mux_sel = 1'b1;
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
                // ram_addr_mux_sel = 1'b1;l
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
                // ram_addr_mux_sel = 1'b1;
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

            end
        endcase
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ir_reg <= 16'h0000;
        end else begin
            ir_reg <= instruction_in;
        end
    end

endmodule