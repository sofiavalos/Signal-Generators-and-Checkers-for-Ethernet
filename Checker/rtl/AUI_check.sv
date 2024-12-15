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
    logic [119:0]           reversed_am  [0:15]; // Para almacenar los valores invertidos de extracted_am
    logic [119:0]           last_am [0:15]; // Para almacenar los valores de extracted_am de la iteración anterior

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
        // Extraer los últimos 120 bits de cada lane si el sync_lane correspondiente está en 1
        extracted_am[0]  = sync_lane_0  ? stored_lanes[0][119:0]  : 120'd0;
        extracted_am[1]  = sync_lane_1  ? stored_lanes[1][119:0]  : 120'd0;
        extracted_am[2]  = sync_lane_2  ? stored_lanes[2][119:0]  : 120'd0;
        extracted_am[3]  = sync_lane_3  ? stored_lanes[3][119:0]  : 120'd0;
        extracted_am[4]  = sync_lane_4  ? stored_lanes[4][119:0]  : 120'd0;
        extracted_am[5]  = sync_lane_5  ? stored_lanes[5][119:0]  : 120'd0;
        extracted_am[6]  = sync_lane_6  ? stored_lanes[6][119:0]  : 120'd0;
        extracted_am[7]  = sync_lane_7  ? stored_lanes[7][119:0]  : 120'd0;
        extracted_am[8]  = sync_lane_8  ? stored_lanes[8][119:0]  : 120'd0;
        extracted_am[9]  = sync_lane_9  ? stored_lanes[9][119:0]  : 120'd0;
        extracted_am[10] = sync_lane_10 ? stored_lanes[10][119:0] : 120'd0;
        extracted_am[11] = sync_lane_11 ? stored_lanes[11][119:0] : 120'd0;
        extracted_am[12] = sync_lane_12 ? stored_lanes[12][119:0] : 120'd0;
        extracted_am[13] = sync_lane_13 ? stored_lanes[13][119:0] : 120'd0;
        extracted_am[14] = sync_lane_14 ? stored_lanes[14][119:0] : 120'd0;
        extracted_am[15] = sync_lane_15 ? stored_lanes[15][119:0] : 120'd0;

        for (int i = 0; i < 16; i++) begin
            // Procesar cada octeto (8 bits) y reordenarlos
            for (int j = 0; j < 15; j++) begin
                reversed_am[i][(j+1)*8-1 -: 8] = extracted_am[i][(15-j)*8-1 -: 8];
            end
        end

        // Comparar los valores invertidos con los esperados
        for (int i = 0; i < 16; i++) begin
            if(reversed_am[i] == expected_am[i]) begin
                sync_flags[i] = 1;
            end else begin
                sync_flags[i] = 0;
            end
        end
        
        // guardar los AM para comparar con la proxima vez
        last_am = reversed_am;

    end

        // Contadores de ciclos entre activaciones de sync_lane
    logic [31:0] cycle_counter [0:15];   // Contador actual de ciclos para cada lane
    logic [31:0] cycle_gap [0:15];       // Valor del gap calculado entre activaciones de cada lane
    logic [15:0] gap_error_flag;         // Bandera de error para gaps diferentes a 8191
    logic [15:0] has_synced;             // Indica si un lane ya ha sido sincronizado al menos una vez

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reiniciar los contadores, los gaps, las banderas de error y las señales de sincronización al reset
            for (int i = 0; i < 16; i++) begin
                cycle_counter[i] <= 32'd0;
                cycle_gap[i] <= 32'd0;
            end
            gap_error_flag <= 16'd0; // Inicializar todas las banderas de error en 0
            has_synced <= 16'd0;     // Inicializar las señales de sincronización en 0
        end else begin
            // Procesar cada línea de sincronización
            if (sync_lane_0) begin
                cycle_gap[0] <= cycle_counter[0];
                cycle_counter[0] <= 32'd0;
                if (has_synced[0] && cycle_counter[0] != 32'd8191) begin
                    gap_error_flag[0] <= 1; // Marcar error si el gap es diferente de 8191 y ya hubo una sincronización previa
                end
                has_synced[0] <= 1; // Indicar que este lane ya fue sincronizado al menos una vez
            end else begin
                cycle_counter[0] <= cycle_counter[0] + 1;
            end

            if (sync_lane_1) begin
                cycle_gap[1] <= cycle_counter[1];
                cycle_counter[1] <= 32'd0;
                if (has_synced[1] && cycle_counter[1] != 32'd8191) begin
                    gap_error_flag[1] <= 1;
                end
                has_synced[1] <= 1;
            end else begin
                cycle_counter[1] <= cycle_counter[1] + 1;
            end

            if (sync_lane_2) begin
                cycle_gap[2] <= cycle_counter[2];
                cycle_counter[2] <= 32'd0;
                if (has_synced[2] && cycle_counter[2] != 32'd8191) begin
                    gap_error_flag[2] <= 1;
                end
                has_synced[2] <= 1;
            end else begin
                cycle_counter[2] <= cycle_counter[2] + 1;
            end

            if (sync_lane_3) begin
                cycle_gap[3] <= cycle_counter[3];
                cycle_counter[3] <= 32'd0;
                if (has_synced[3] && cycle_counter[3] != 32'd8191) begin
                    gap_error_flag[3] <= 1;
                end
                has_synced[3] <= 1;
            end else begin
                cycle_counter[3] <= cycle_counter[3] + 1;
            end

            if (sync_lane_4) begin
                cycle_gap[4] <= cycle_counter[4];
                cycle_counter[4] <= 32'd0;
                if (has_synced[4] && cycle_counter[4] != 32'd8191) begin
                    gap_error_flag[4] <= 1;
                end
                has_synced[4] <= 1;
            end else begin
                cycle_counter[4] <= cycle_counter[4] + 1;
            end

            if (sync_lane_5) begin
                cycle_gap[5] <= cycle_counter[5];
                cycle_counter[5] <= 32'd0;
                if (has_synced[5] && cycle_counter[5] != 32'd8191) begin
                    gap_error_flag[5] <= 1;
                end
                has_synced[5] <= 1;
            end else begin
                cycle_counter[5] <= cycle_counter[5] + 1;
            end

            if (sync_lane_6) begin
                cycle_gap[6] <= cycle_counter[6];
                cycle_counter[6] <= 32'd0;
                if (has_synced[6] && cycle_counter[6] != 32'd8191) begin
                    gap_error_flag[6] <= 1;
                end
                has_synced[6] <= 1;
            end else begin
                cycle_counter[6] <= cycle_counter[6] + 1;
            end

            if (sync_lane_7) begin
                cycle_gap[7] <= cycle_counter[7];
                cycle_counter[7] <= 32'd0;
                if (has_synced[7] && cycle_counter[7] != 32'd8191) begin
                    gap_error_flag[7] <= 1;
                end
                has_synced[7] <= 1;
            end else begin
                cycle_counter[7] <= cycle_counter[7] + 1;
            end

            if (sync_lane_8) begin
                cycle_gap[8] <= cycle_counter[8];
                cycle_counter[8] <= 32'd0;
                if (has_synced[8] && cycle_counter[8] != 32'd8191) begin
                    gap_error_flag[8] <= 1;
                end
                has_synced[8] <= 1;
            end else begin
                cycle_counter[8] <= cycle_counter[8] + 1;
            end

            if (sync_lane_9) begin
                cycle_gap[9] <= cycle_counter[9];
                cycle_counter[9] <= 32'd0;
                if (has_synced[9] && cycle_counter[9] != 32'd8191) begin
                    gap_error_flag[9] <= 1;
                end
                has_synced[9] <= 1;
            end else begin
                cycle_counter[9] <= cycle_counter[9] + 1;
            end

            if (sync_lane_10) begin
                cycle_gap[10] <= cycle_counter[10];
                cycle_counter[10] <= 32'd0;
                if (has_synced[10] && cycle_counter[10] != 32'd8191) begin
                    gap_error_flag[10] <= 1;
                end
                has_synced[10] <= 1;
            end else begin
                cycle_counter[10] <= cycle_counter[10] + 1;
            end

            if (sync_lane_11) begin
                cycle_gap[11] <= cycle_counter[11];
                cycle_counter[11] <= 32'd0;
                if (has_synced[11] && cycle_counter[11] != 32'd8191) begin
                    gap_error_flag[11] <= 1;
                end
                has_synced[11] <= 1;
            end else begin
                cycle_counter[11] <= cycle_counter[11] + 1;
            end

            if (sync_lane_12) begin
                cycle_gap[12] <= cycle_counter[12];
                cycle_counter[12] <= 32'd0;
                if (has_synced[12] && cycle_counter[12] != 32'd8191) begin
                    gap_error_flag[12] <= 1;
                end
                has_synced[12] <= 1;
            end else begin
                cycle_counter[12] <= cycle_counter[12] + 1;
            end

            if (sync_lane_13) begin
                cycle_gap[13] <= cycle_counter[13];
                cycle_counter[13] <= 32'd0;
                if (has_synced[13] && cycle_counter[13] != 32'd8191) begin
                    gap_error_flag[13] <= 1;
                end
                has_synced[13] <= 1;
            end else begin
                cycle_counter[13] <= cycle_counter[13] + 1;
            end

            if (sync_lane_14) begin
                cycle_gap[14] <= cycle_counter[14];
                cycle_counter[14] <= 32'd0;
                if (has_synced[14] && cycle_counter[14] != 32'd8191) begin
                    gap_error_flag[14] <= 1;
                end
                has_synced[14] <= 1;
            end else begin
                cycle_counter[14] <= cycle_counter[14] + 1;
            end

            if (sync_lane_15) begin
                cycle_gap[15] <= cycle_counter[15];
                cycle_counter[15] <= 32'd0;
                if (has_synced[15] && cycle_counter[15] != 32'd8191) begin
                    gap_error_flag[15] <= 1;
                end
                has_synced[15] <= 1;
            end else begin
                cycle_counter[15] <= cycle_counter[15] + 1;
            end
        end
    end





endmodule