// accumulator.v - 8-bit Accumulator module

module accumulator (
    input wire clk,           
    input wire reset_n,       
    input wire acc_load_en,  
    input wire [7:0] data_in, 
    output reg [7:0] acc_out  
);

    
    initial begin
        acc_out = 8'h00; 
    end

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            acc_out <= 8'h00;
        end else if (acc_load_en) begin
            acc_out <= data_in;
        end
    end

endmodule