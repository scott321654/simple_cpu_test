// accumulator.v - 8-bit Accumulator module

module accumulator (
    input wire clk,           // 時鐘輸入
    input wire reset_n,       // 非同步低電位有效重置
    input wire acc_load_en,  // 累加器載入使能訊號
    input wire [7:0] data_in, // 要載入到累加器的 8 位元資料
    output reg [7:0] acc_out  // 累加器當前的 8 位元輸出值
);

    // 初始塊：僅用於模擬目的，將累加器初始化為 0
    // 在實際 FPGA 硬體中，重置訊號 (reset_n) 會處理其初始狀態
    initial begin
        acc_out = 8'h00; // 將累加器初始值設為 0
    end

    // 時序邏輯：在時鐘上升緣或重置訊號下降緣時更新累加器
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // 當重置訊號為低電位時，將累加器歸零
            acc_out <= 8'h00;
        end else if (acc_load_en) begin
            // 如果載入使能為高電位，則載入 data_in 的值
            acc_out <= data_in;
        end
        // 如果 acc_load_en 為低電位，累加器會保持其當前值（保持不變）
    end

endmodule