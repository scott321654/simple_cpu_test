// ram.v - 16-bit Dual-Port RAM module for Simple CPU (ModelSim Friendly)

module ram (
    input wire clk,

    // Port A: For Instruction Fetch
    input wire [7:0] addr_a,            // Address for instruction fetch
    output wire [15:0] data_out_a,      // Instruction fetched

    // Port B: For Data Access
    input wire we_b,                    // Write Enable for data port
    input wire [7:0] addr_b,            // Address for data access
    input wire [15:0] data_in_b,        // Data to write
    output wire [15:0] data_out_b        // Data read
);
	/* I don't know why I've imported mif or hex file 
	/* but it didn't work. So hardcode is my last hope
	 */
    reg [15:0] mem [255:0];
    integer i;

    initial begin
       
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 16'h0000;
        end

        mem[8'h00] = 16'h1005;  // test value:0x5
        mem[8'h01] = 16'h3003;  // test value:0x3
        mem[8'h02] = 16'h20FF;  // store value in 0xff
        mem[8'h03] = 16'h7000;  
		  
        // data setion
        mem[8'h80] = 16'h000A;  
        mem[8'hFF] = 16'h0000;  // clean value in 0xff
    end

    always @(posedge clk) begin
        if (we_b) begin
            mem[addr_b] <= data_in_b;
        end
    end

    assign data_out_a = mem[addr_a];
    assign data_out_b = mem[addr_b];

endmodule