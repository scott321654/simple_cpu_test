// alu.v - 
module alu (
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [3:0] opcode,
    output reg [7:0] result,
    output reg carry_out
);

    reg [8:0] sum_extended;
    reg [8:0] sub_extended;

    // Define ALU OpCodes
    parameter OP_ADD = 4'b0000;
    parameter OP_SUB = 4'b0001;
    parameter OP_AND = 4'b0010;
    parameter OP_INC = 4'b0011;

    always @(*) begin
        // 預設值 for all 'reg' variables in this always block
        result = 8'h00;
        carry_out = 1'b0;
        sum_extended = 9'h000; // <--- 修正: 預設值
        sub_extended = 9'h000; // <--- 修正: 預設值

        case (opcode)
            OP_ADD: begin
                sum_extended = {1'b0, a} + {1'b0, b};
                result = sum_extended[7:0];
                carry_out = sum_extended[8];
            end
            OP_SUB: begin
                sub_extended = {1'b0, a} - {1'b0, b};
                result = sub_extended[7:0];
                carry_out = !sub_extended[8];
            end
            OP_AND: begin
                result = a & b;
                // carry_out 已經有預設值，無需在此重複設置為 0
            end
            OP_INC: begin
                sum_extended = {1'b0, a} + {1'b0, 8'h01};
                result = sum_extended[7:0];
                carry_out = sum_extended[8];
            end
            default: begin
                // 預設值已經在 always 塊開頭設定，無需在此重複
            end
        endcase
    end

endmodule