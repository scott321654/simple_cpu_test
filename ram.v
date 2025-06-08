// ram.v - 16-bit Dual-Port RAM module for Simple CPU (ModelSim Friendly)

module ram (
    input wire clk,

    // Port A: For Instruction Fetch
    input wire [7:0] addr_a,            // Address for instruction fetch
    output wire [15:0] data_out_a,      // Instruction fetched

    // Port B: For Data Access (Load/Store)
    input wire we_b,                    // Write Enable for data port
    input wire [7:0] addr_b,            // Address for data access
    input wire [15:0] data_in_b,        // Data to write
    output wire [15:0] data_out_b        // Data read
);

    reg [15:0] mem [255:0];
    integer i;

    initial begin
        // 1. 先將所有記憶體位置初始化為 0 (防止有任何 X 狀態)
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 16'h0000;
        end

        // --- 程式碼和數據初始化 (不變) ---
        mem[8'h00] = 16'h1005;  // 位址 0x00: LOAD_ACC_IMM 0x05
        mem[8'h01] = 16'h3003;  // 位址 0x01: ADD_ACC_IMM 0x03
        mem[8'h02] = 16'h20FF;  // 位址 0x02: STORE_ACC_MEM 0xFF
        mem[8'h03] = 16'h7000;  // 位址 0x03: JUMP 0x00
        // 數據區域
        mem[8'h80] = 16'h000A;  // 數據 0x0A
        mem[8'hFF] = 16'h0000;  // 數據 0x00 (STORE 的目標)
    end

    // Port B 寫入邏輯：同步寫入 (針對資料埠)
    always @(posedge clk) begin
        if (we_b) begin
            mem[addr_b] <= data_in_b;
        end
    end

    // Port A 讀取邏輯：組合邏輯讀取 (非同步讀取，針對指令埠)
    assign data_out_a = mem[addr_a];

    // Port B 讀取邏輯：組合邏輯讀取 (非同步讀取，針對資料埠)
    assign data_out_b = mem[addr_b];

endmodule