// ram.v - 16-bit RAM module for Simple CPU (ModelSim Friendly)

module ram (
    input wire clk,
    input wire we,
    input wire [7:0] addr,
    input wire [15:0] data_in,
    output wire [15:0] data_out
);

    reg [15:0] mem [255:0]; 
    integer i;

    initial begin
        // 1. 先將所有記憶體位置初始化為 0 (防止有任何 X 狀態)
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 16'h0000; 
        end
        
        // --- 修正點：確保程式碼和數據在 for 迴圈後被賦值 ---
        // 這樣可以保證這些特定的記憶體位置被正確地設定，不會被前面的 for 迴圈覆蓋。
        mem[8'h00] = 16'h1005;  // 位址 0x00: LOAD_ACC_IMM 0x05
        mem[8'h01] = 16'h3003;  // 位址 0x01: ADD_ACC_IMM 0x03
        mem[8'h02] = 16'h20FF;  // 位址 0x02: STORE_ACC_MEM 0xFF
        mem[8'h03] = 16'h7000;  // 位址 0x03: JUMP 0x00

        // 數據區域 (如果你有，也要在這裡明確賦值)
        mem[8'h80] = 16'h000A;  // 數據 0x0A
        mem[8'h81] = 16'h0000;  // 數據 0x00 (STORE 的目標)
    end

    // 記憶體寫入邏輯：同步寫入
    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= data_in;
        end
    end

    // 記憶體讀取邏輯：組合邏輯讀取（非同步讀取）
    assign data_out = mem[addr];

endmodule