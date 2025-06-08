// ram.v - 16-bit RAM module for Simple CPU (ModelSim Friendly)
// This module serves as both Instruction and Data Memory.
// It features synchronous write and asynchronous (combinational) read.
// *** Initial memory content is now directly embedded in this file. ***

module ram (
    input wire clk,             // 時鐘輸入：用於同步寫入操作
    input wire we,              // 寫入使能：當此訊號為高電位時，data_in 會被寫入到指定位址
    input wire [7:0] addr,      // 8 位元位址輸入：可以存取 2^8 = 256 個記憶體位置
    input wire [15:0] data_in,  // 16 位元資料輸入：要寫入記憶體的資料
    output wire [15:0] data_out // 16 位元資料輸出：從記憶體讀取到的資料
);

    // 宣告一個 256 x 16 位元 的記憶體陣列
    reg [15:0] mem [255:0]; 
    
    // 將 'i' 的宣告移到這裡，模組級別
    integer i; // <-- 將這行從 initial 區塊內移到這裡

    // 初始化記憶體內容
    initial begin
        // 'i' 現在已經在模組級別宣告了
        for (i = 0; i < 256; i = i + 1) begin
            mem[i] = 16'h0000;
        end
        
        // --- 嵌入您的 CPU 程式碼 ---
        // 位址 0x00: LOAD_ACC_IMM 0x05 (Opcode 10, Operand 05)
        mem[8'h00] = 16'h1005; 

        // 位址 0x01: ADD_ACC_IMM 0x03 (Opcode 30, Operand 03)
        mem[8'h01] = 16'h3003; 

        // 位址 0x02: STORE_ACC_MEM 0xFF (Opcode 20, Operand FF)
        mem[8'h02] = 16'h20FF; 

       // 位址 0x03: JUMP 0x00 (Opcode 70, Operand 00)
        mem[8'h03] = 16'h7000; 

        // 您也可以在這裡初始化其他數據記憶體位置，例如：
        // mem[8'h10] = 16'hABCD; // 範例數據
    end

    // 記憶體寫入邏輯：同步寫入
    always @(posedge clk) begin
        if (we) begin
            mem[addr] <= data_in; // 將 data_in 寫入到指定位址
        end
    end

    // 記憶體讀取邏輯：組合邏輯讀取（非同步讀取）
    assign data_out = mem[addr];

endmodule
