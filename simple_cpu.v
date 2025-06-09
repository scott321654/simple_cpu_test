// simple_cpu.v - Top-level module for the Simple CPU on DE10-Standard

module simple_cpu (
    input wire clk_50mhz,        
    input wire key0_n,           
    // debug only
    output wire [7:0] debug_output_acc,      // accumulator
    output wire [7:0] debug_pc_out,          // program counter 
    output wire [15:0] debug_instruction_out // current instruction
);

    // 
    // Definitions in ir_decoder.v
    parameter OP_NO_OP            = 8'h00;
    parameter OP_LOAD_ACC_IMM     = 8'h10;
    parameter OP_LOAD_ACC_MEM     = 8'h11;
    parameter OP_STORE_ACC_MEM    = 8'h20;
    parameter OP_ADD_ACC_IMM      = 8'h30;
    parameter OP_ADD_ACC_MEM      = 8'h31;
    parameter OP_SUB_ACC_IMM      = 8'h40;
    parameter OP_SUB_ACC_MEM      = 8'h41;
    parameter OP_AND_ACC_IMM      = 8'h50;
    parameter OP_AND_ACC_MEM      = 8'h51;
    parameter OP_INC_ACC          = 8'h60;
    parameter OP_JUMP             = 8'h70;
    parameter OP_OUT_ACC_SERIAL   = 8'h80;


    wire [7:0] pc_out;
    wire pc_load_en;
    wire [7:0] jump_addr;

    wire [15:0] instruction_from_ram_inst; 

    wire [7:0] ram_data_addr;           
    wire [15:0] ram_data_in_data;       
    wire ram_we_data;                   
    wire [15:0] data_from_ram_data;     


    wire [7:0] decoded_immediate_operand; 
    // wire ram_addr_mux_sel;             // I use dual-port RAM INSTEAD
    wire [3:0] alu_opcode;
    wire alu_a_mux_sel;                  
    wire alu_b_mux_sel;                  
    wire acc_load_en;                    
    wire serial_out_en;                  
    wire [7:0] decoded_opcode;           

    // ACC related signals
    wire [7:0] acc_out;
    wire [7:0] acc_data_in_muxed;        

    // ALU related signals
    wire [7:0] alu_a_input;
    wire [7:0] alu_b_input;
    wire [7:0] alu_result;
    wire alu_carry_out;                  



    // Program Counter
    program_counter u_pc (
        .clk(clk_50mhz),
        .reset_n(key0_n),
        .load_en(pc_load_en),
        .next_addr_in(jump_addr),
        .pc_out(pc_out)
    );

    ram u_ram (
        .clk(clk_50mhz),

        .addr_a(pc_out),                        
        .data_out_a(instruction_from_ram_inst), 

        .we_b(ram_we_data),                     
        .addr_b(ram_data_addr),                 
        .data_in_b(ram_data_in_data),           
        .data_out_b(data_from_ram_data)         
    );

    // Connections for Dual-Port RAM
    assign ram_data_addr = decoded_immediate_operand;
    assign ram_data_in_data = {8'h00, acc_out};      

    ir_decoder u_ir_decoder (
        .clk(clk_50mhz),
        .reset_n(key0_n),
        .instruction_in(instruction_from_ram_inst), // Instruction from RAM's Port A

        .pc_load_en(pc_load_en),
        .jump_addr(jump_addr),

        .ram_we(ram_we_data),                      
        // .ram_addr_mux_sel(ram_addr_mux_sel),    // REMOVED: No longer needed for muxing RAM address

        .alu_opcode(alu_opcode),
        .alu_a_mux_sel(alu_a_mux_sel),
        .alu_b_mux_sel(alu_b_mux_sel),

        .acc_load_en(acc_load_en),

        .immediate_operand(decoded_immediate_operand),
        .serial_out_en(serial_out_en),
        .decoded_opcode_out(decoded_opcode)
    );

    // Accumulator
    accumulator u_acc (
        .clk(clk_50mhz),
        .reset_n(key0_n),
        .acc_load_en(acc_load_en),
        .data_in(acc_data_in_muxed),
        .acc_out(acc_out)
    );

	// Data from RAM Port B
    assign acc_data_in_muxed =
        (decoded_opcode == OP_LOAD_ACC_IMM)  ? decoded_immediate_operand :
        (decoded_opcode == OP_LOAD_ACC_MEM)  ? data_from_ram_data[7:0]   : 
        alu_result;

    // ALU
    alu u_alu (
        .a(alu_a_input),
        .b(alu_b_input),
        .opcode(alu_opcode),
        .result(alu_result),
        .carry_out(alu_carry_out)
    );

    // Mux for ALU Operand A: In this simple CPU, ALU A is always from Accumulator
    assign alu_a_input = acc_out;
    // Mux for ALU Operand B: Selects between Immediate_Operand and Lower 8 bits of RAM data (from Port B)
    assign alu_b_input = (alu_b_mux_sel == 1'b0) ? decoded_immediate_operand : data_from_ram_data[7:0]; // Data from RAM Port B

    assign debug_output_acc = acc_out;
    assign debug_pc_out = pc_out;
    assign debug_instruction_out = instruction_from_ram_inst; // Now specifically instruction from Port A

endmodule