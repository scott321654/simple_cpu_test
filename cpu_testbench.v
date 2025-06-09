// cpu_testbench.v - Testbench for Simple CPU

module cpu_testbench;

    
    reg clk_50mhz;       
    reg key0_n;          

    
    wire [7:0] debug_output_acc;
    wire [7:0] debug_pc_out;
    wire [15:0] debug_instruction_out;

   
    // test uut
    simple_cpu uut (
        .clk_50mhz             (clk_50mhz),
        .key0_n                (key0_n),
        .debug_output_acc      (debug_output_acc),
        .debug_pc_out          (debug_pc_out),
        .debug_instruction_out (debug_instruction_out)
    );

   
    parameter CLK_PERIOD = 20; // 20 ns for 50MHz

    initial begin
        clk_50mhz = 1'b0; 
        forever begin
            #(CLK_PERIOD / 2) clk_50mhz = ~clk_50mhz; 
        end
    end

    initial begin
        
        key0_n = 1'b0;    
        #100;             
        key0_n = 1'b1;    
        #2000;
        $finish;
    end

    initial begin
        $dumpfile("simple_cpu.vcd"); 
        $dumpvars(0, cpu_testbench); 
    end

endmodule