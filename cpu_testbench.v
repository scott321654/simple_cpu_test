// cpu_testbench.v - Testbench for Simple CPU

module cpu_testbench;

    // --- Testbench Signals (Connect to simple_cpu's ports) ---
    reg clk_50mhz;       // 模擬時鐘
    reg key0_n;          // 模擬重置按鈕

    // 連接 simple_cpu 的偵錯輸出埠，以便在波形中觀察
    wire [7:0] debug_output_acc;
    wire [7:0] debug_pc_out;
    wire [15:0] debug_instruction_out;

    // --- Instantiate the Unit Under Test (UUT) ---
    // 例化你的 simple_cpu 模組
    simple_cpu uut (
        .clk_50mhz             (clk_50mhz),
        .key0_n                (key0_n),
        .debug_output_acc      (debug_output_acc),
        .debug_pc_out          (debug_pc_out),
        .debug_instruction_out (debug_instruction_out)
    );

    // --- Clock Generation ---
    // 產生 50MHz 時鐘 (週期 20ns，半週期 10ns)
    parameter CLK_PERIOD = 20; // 20 ns for 50MHz

    initial begin
        clk_50mhz = 1'b0; // 初始時鐘為低電位
        forever begin
            #(CLK_PERIOD / 2) clk_50mhz = ~clk_50mhz; // 每半個週期翻轉
        end
    end

    // --- Reset Generation and Simulation Control ---
    initial begin
        // 初始重置 (低電位有效)
        key0_n = 1'b0;    // Assert reset
        #100;             // 保持重置 100ns (足以讓所有寄存器復位)
        key0_n = 1'b1;    // Deassert reset (CPU 開始運行)

        // --- 模擬結束條件 ---
        // 運行一段時間後結束模擬，或者在特定事件發生時結束
        // 這裡設定運行 2000ns 後結束 (足以執行一些指令)
        #2000;
        $finish; // 結束模擬

        // --- 偵錯信息輸出到 ModelSim 控制台 (Transcript Window) ---
        // 僅修改 $monitor 語句，以反映雙埠記憶體相關的新訊號名稱
        // 確保你的 program.mif 有有效的指令
    end

    // --- 波形傾印 (用於 ModelSim/VCS 等工具) ---
    // 推薦保留 $dumpvars，它可以幫助你看到所有內部訊號，這是最直接的偵錯方式
    initial begin
        $dumpfile("simple_cpu.vcd"); // 輸出 VCD 檔案
        $dumpvars(0, cpu_testbench); // 傾印所有訊號
    end

endmodule