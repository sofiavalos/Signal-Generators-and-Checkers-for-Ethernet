module aui_testbench;
    // Parameters
    parameter DATA_WIDTH = 64;
    parameter NUMBER_LANES = 16;
    parameter BITS_BLOCK = 257;
    parameter LANE_WIDTH = 1360;

    // Signals
    logic clk;
    logic rst;

    reg [3:0]hexa_output;

    wire [BITS_BLOCK-1:0]o_flow0;
    wire [BITS_BLOCK-1:0]o_flow1;
    
    wire [LANE_WIDTH-1:0] w_lane_0;     // Wires para conectar los 16 canales
    wire [LANE_WIDTH-1:0] w_lane_1;
    wire [LANE_WIDTH-1:0] w_lane_2;
    wire [LANE_WIDTH-1:0] w_lane_3;
    wire [LANE_WIDTH-1:0] w_lane_4;
    wire [LANE_WIDTH-1:0] w_lane_5;
    wire [LANE_WIDTH-1:0] w_lane_6;
    wire [LANE_WIDTH-1:0] w_lane_7;
    wire [LANE_WIDTH-1:0] w_lane_8;
    wire [LANE_WIDTH-1:0] w_lane_9;
    wire [LANE_WIDTH-1:0] w_lane_10;
    wire [LANE_WIDTH-1:0] w_lane_11;
    wire [LANE_WIDTH-1:0] w_lane_12;
    wire [LANE_WIDTH-1:0] w_lane_13;
    wire [LANE_WIDTH-1:0] w_lane_14;
    wire [LANE_WIDTH-1:0] w_lane_15;

    wire sync_lane_0;
    wire sync_lane_1;
    wire sync_lane_2;
    wire sync_lane_3;
    wire sync_lane_4;
    wire sync_lane_5;
    wire sync_lane_6;
    wire sync_lane_7;
    wire sync_lane_8;
    wire sync_lane_9;
    wire sync_lane_10;
    wire sync_lane_11;
    wire sync_lane_12;
    wire sync_lane_13;
    wire sync_lane_14;
    wire sync_lane_15;



    // Instancia generador

    aui_generator #(
        .BITS_BLOCK(BITS_BLOCK)
    ) aui_test (
        .clk(clk),
        .rst(rst),
        .hexa_output(hexa_output),
        .o_flow_0(o_flow0),
        .o_flow_1(o_flow1),
        
        .o_lane_0(w_lane_0), 
        .o_lane_1(w_lane_1), 
        .o_lane_2(w_lane_2), 
        .o_lane_3(w_lane_3), 
        .o_lane_4(w_lane_4), 
        .o_lane_5(w_lane_5), 
        .o_lane_6(w_lane_6), 
        .o_lane_7(w_lane_7), 
        .o_lane_8(w_lane_8), 
        .o_lane_9(w_lane_9), 
        .o_lane_10(w_lane_10), 
        .o_lane_11(w_lane_11), 
        .o_lane_12(w_lane_12), 
        .o_lane_13(w_lane_13), 
        .o_lane_14(w_lane_14), 
        .o_lane_15(w_lane_15),
        .sync_lane_0(sync_lane_0),
        .sync_lane_1(sync_lane_1),
        .sync_lane_2(sync_lane_2),
        .sync_lane_3(sync_lane_3),
        .sync_lane_4(sync_lane_4),
        .sync_lane_5(sync_lane_5),
        .sync_lane_6(sync_lane_6),
        .sync_lane_7(sync_lane_7),
        .sync_lane_8(sync_lane_8),
        .sync_lane_9(sync_lane_9),
        .sync_lane_10(sync_lane_10),
        .sync_lane_11(sync_lane_11),
        .sync_lane_12(sync_lane_12),
        .sync_lane_13(sync_lane_13),
        .sync_lane_14(sync_lane_14),
        .sync_lane_15(sync_lane_15)
    );
    
    
    
    // Instancia checker
    
    aui_checker #(
        .LANE_WIDTH(LANE_WIDTH),
        .BITS_BLOCK(BITS_BLOCK)
    ) aui_chk (
        .clk(clk),
        .rst(rst),
        .i_lane_0(w_lane_0), 
        .i_lane_1(w_lane_1),
        .i_lane_2(w_lane_2), 
        .i_lane_3(w_lane_3),
        .i_lane_4(w_lane_4), 
        .i_lane_5(w_lane_5),
        .i_lane_6(w_lane_6), 
        .i_lane_7(w_lane_7),
        .i_lane_8(w_lane_8), 
        .i_lane_9(w_lane_9),
        .i_lane_10(w_lane_10), 
        .i_lane_11(w_lane_11),
        .i_lane_12(w_lane_12), 
        .i_lane_13(w_lane_13),
        .i_lane_14(w_lane_14), 
        .i_lane_15(w_lane_15),
        .sync_lane_0(sync_lane_0),
        .sync_lane_1(sync_lane_1),
        .sync_lane_2(sync_lane_2),
        .sync_lane_3(sync_lane_3),
        .sync_lane_4(sync_lane_4),
        .sync_lane_5(sync_lane_5),
        .sync_lane_6(sync_lane_6),
        .sync_lane_7(sync_lane_7),
        .sync_lane_8(sync_lane_8),
        .sync_lane_9(sync_lane_9),
        .sync_lane_10(sync_lane_10),
        .sync_lane_11(sync_lane_11),
        .sync_lane_12(sync_lane_12),
        .sync_lane_13(sync_lane_13),
        .sync_lane_14(sync_lane_14),
        .sync_lane_15(sync_lane_15)
    );
    
    
    
    // Clock generation
    initial begin
        clk = 0;
        forever #2 clk = ~clk; // 100 MHz clock
    end

    // Reset generation
    initial begin
        rst = 1;
        #20 rst = 0;
        #5000;
    end

    // Simulation control
    initial begin
        // Run the simulation for a specific time
        #100000;
        $finish;
    end

    // Dump waveforms for GTKWave
    initial begin
    $dumpfile("aui_testbench.vcd");   // Specify VCD file for gtkwave
    $dumpvars(0, aui_testbench); // Start dumping signals from the top module
end

endmodule
