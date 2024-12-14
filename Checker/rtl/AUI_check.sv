module aui_checker #(
    parameter BITS_BLOCK    = 257,
    parameter MAX_BLOCKS_AM = 40,
    parameter WORD_SIZE     = 10, 
    parameter LANE_WIDTH    = 1360
)(
    input logic clk,
    input logic rst,
    input logic [LANE_WIDTH-1:0] i_lane_0,  // 16 lanes de 1360 bits c/u
    input logic sync_lane_0,
    input logic [LANE_WIDTH-1:0] i_lane_1,
    input logic sync_lane_1,
    input logic [LANE_WIDTH-1:0] i_lane_2,
    input logic sync_lane_2,
    input logic [LANE_WIDTH-1:0] i_lane_3,
    input logic sync_lane_3,
    input logic [LANE_WIDTH-1:0] i_lane_4,
    input logic sync_lane_4,
    input logic [LANE_WIDTH-1:0] i_lane_5,
    input logic sync_lane_5,
    input logic [LANE_WIDTH-1:0] i_lane_6,
    input logic sync_lane_6,
    input logic [LANE_WIDTH-1:0] i_lane_7,
    input logic sync_lane_7,
    input logic [LANE_WIDTH-1:0] i_lane_8,
    input logic sync_lane_8,
    input logic [LANE_WIDTH-1:0] i_lane_9,
    input logic sync_lane_9,
    input logic [LANE_WIDTH-1:0] i_lane_10,
    input logic sync_lane_10,
    input logic [LANE_WIDTH-1:0] i_lane_11,
    input logic sync_lane_11,
    input logic [LANE_WIDTH-1:0] i_lane_12,
    input logic sync_lane_12,
    input logic [LANE_WIDTH-1:0] i_lane_13,
    input logic sync_lane_13,
    input logic [LANE_WIDTH-1:0] i_lane_14,
    input logic sync_lane_14,
    input logic [LANE_WIDTH-1:0] i_lane_15,
    input logic sync_lane_15,

    output logic valid_pattern,
    output logic [15:0] lane_error
);

    // Alignment markers esperados segun estandar
    logic [119:0]           expected_am  [0:15];    // 16 vias de 120 bits cada una
    logic [LANE_WIDTH-1:0]  stored_lanes [0:15];    // Registros para almacenar cada lane
    logic [119:0]           extracted_am [0:15];    // Registros para los primeros 120 bits de cada lane

    initial begin   //         C C C N C C C N N N N N N N N
        expected_am[0]  = 120'h9A4A26B665B5D9D9FE8E0C260171F3;
        expected_am[1]  = 120'h9A4A260465b5d967a52181985ade7e;
        expected_am[2]  = 120'h9a4a264665b5d9fec10ca9013ef356;
        expected_am[3]  = 120'h9a4a265a65b5d984797f2f7b8680d0;
        expected_am[4]  = 120'h9a4a26e165b5d919d5ae0de62a51f2;
        expected_am[5]  = 120'h9a4a26f265b5d94eedb02eb1124fd1;
        expected_am[6]  = 120'h9a4a263d65b5d9eebd635e11429ca1;
        expected_am[7]  = 120'h9a4a262265b5d9322989a4cdd6765b;
        expected_am[8]  = 120'h9a4a266065b5d99f1e8c8a60e17375;
        expected_am[9]  = 120'h9a4a266b65b5d9a28e3bc35d71c43c;
        expected_am[10] = 120'h9a4a26fa65b5d9046a1427fb95ebd8;
        expected_am[11] = 120'h9a4a266c65b5d971dd99c78e226638;
        expected_am[12] = 120'h9a4a261865b5d95b5d096aa4a2f695;
        expected_am[13] = 120'h9a4a261465b5d9ccce683c333197c3;
        expected_am[14] = 120'h9a4a26d065b5d9b13504594ecafba6;
        expected_am[15] = 120'h9a4a26b465b5d956594586a9a6ba79;
    end
    
    logic [15:0] sync_flags;
    logic [15:0] pattern_checks;
    
    always_comb begin
        // Almacenar cada lane completo
        stored_lanes[0]  = i_lane_0;
        stored_lanes[1]  = i_lane_1;
        stored_lanes[2]  = i_lane_2;
        stored_lanes[3]  = i_lane_3;
        stored_lanes[4]  = i_lane_4;
        stored_lanes[5]  = i_lane_5;
        stored_lanes[6]  = i_lane_6;
        stored_lanes[7]  = i_lane_7;
        stored_lanes[8]  = i_lane_8;
        stored_lanes[9]  = i_lane_9;
        stored_lanes[10] = i_lane_10;
        stored_lanes[11] = i_lane_11;
        stored_lanes[12] = i_lane_12;
        stored_lanes[13] = i_lane_13;
        stored_lanes[14] = i_lane_14;
        stored_lanes[15] = i_lane_15;
        
        // Cargar los valores solo si el sync_lane correspondiente está activo
        if (sync_lane_0)  extracted_am[0]  <= stored_lanes[0][119:0];
        if (sync_lane_1)  extracted_am[1]  <= stored_lanes[1][119:0];
        if (sync_lane_2)  extracted_am[2]  <= stored_lanes[2][119:0];
        if (sync_lane_3)  extracted_am[3]  <= stored_lanes[3][119:0];
        if (sync_lane_4)  extracted_am[4]  <= stored_lanes[4][119:0];
        if (sync_lane_5)  extracted_am[5]  <= stored_lanes[5][119:0];
        if (sync_lane_6)  extracted_am[6]  <= stored_lanes[6][119:0];
        if (sync_lane_7)  extracted_am[7]  <= stored_lanes[7][119:0];
        if (sync_lane_8)  extracted_am[8]  <= stored_lanes[8][119:0];
        if (sync_lane_9)  extracted_am[9]  <= stored_lanes[9][119:0];
        if (sync_lane_10) extracted_am[10] <= stored_lanes[10][119:0];
        if (sync_lane_11) extracted_am[11] <= stored_lanes[11][119:0];
        if (sync_lane_12) extracted_am[12] <= stored_lanes[12][119:0];
        if (sync_lane_13) extracted_am[13] <= stored_lanes[13][119:0];
        if (sync_lane_14) extracted_am[14] <= stored_lanes[14][119:0];
        if (sync_lane_15) extracted_am[15] <= stored_lanes[15][119:0];

        // Comparar los AM extraídos con los esperados
        for (int i = 0; i < 16; i++) begin
            pattern_checks[i] = (extracted_am[i] == expected_am[i]);
        end

        // Validar los patrones
        valid_pattern = &pattern_checks;
    end

endmodule