module aui_checker #(
    parameter BITS_BLOCK    = 257,
    parameter MAX_BLOCKS_AM = 40,
    parameter WORD_SIZE     = 10, 
    parameter LANE_WIDTH    = 1360,
    parameter CODEWORD_WIDTH = 5440
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


    localparam AM_WIDTH = 120; // ancho de los AMs
    localparam AM_LANES = 16; // cantidad de lineas
    localparam AM_LANES_WIDTH = $clog2(AM_LANES); // ancho de las lineas
    localparam BYTE_SIZE = 8; 
    localparam TOTAL_CYCLES = 8191; // cantidad de ciclos hasta la aparicion de los AM's
    localparam TOTAL_CYCLES_WIDTH = $clog2(TOTAL_CYCLES);
    localparam ROUND_ROBIN_BITS = 10;
    localparam TOTAL_CODEWORDS = 4;
    localparam TOTAL_ITERATIONS = LANE_WIDTH / (TOTAL_CODEWORDS * ROUND_ROBIN_BITS);
    localparam FEC_WIDTH = 300;
    localparam CODEWORD_WIDTH_WO_FEC = CODEWORD_WIDTH - FEC_WIDTH;
    localparam BLOCK_W_AM_WIDTH = CODEWORD_WIDTH_WO_FEC * 2;
    localparam AM_MAPPED_WIDTH = 1028;
    localparam BLOCK_WO_AM_WIDTH = BLOCK_W_AM_WIDTH - AM_MAPPED_WIDTH;


    // AMs ya invertidos para comparar directamente con los que ingresan
    localparam [AM_WIDTH - 1 : 0]
        EXPECTED_AM_LANE_0  = 120'hF37101260C8EFED9D9B565B6264A9A,
        EXPECTED_AM_LANE_1  = 120'h7EDE5A988121A567D9B56504264A9A,
        EXPECTED_AM_LANE_2  = 120'h56F33E01A90CC1FED9B56546264A9A,
        EXPECTED_AM_LANE_3  = 120'hD080867B2F7F7984D9B5655A264A9A,
        EXPECTED_AM_LANE_4  = 120'hF2512AE60DAED519D9B565E1264A9A,
        EXPECTED_AM_LANE_5  = 120'hD14F12B12EB0ED4ED9B565F2264A9A,
        EXPECTED_AM_LANE_6  = 120'hA19C42115E63BDEED9B5653D264A9A,
        EXPECTED_AM_LANE_7  = 120'h5B76D6CDA4892932D9B56522264A9A,
        EXPECTED_AM_LANE_8  = 120'h7573E1608A8C1E9FD9B56560264A9A,
        EXPECTED_AM_LANE_9  = 120'h3CC4715DC33B8EA2D9B5656B264A9A,
        EXPECTED_AM_LANE_10 = 120'hD8EB95FB27146A04D9B565FA264A9A,
        EXPECTED_AM_LANE_11 = 120'h3866228EC799DD71D9B5656C264A9A,
        EXPECTED_AM_LANE_12 = 120'h95F6A2A46A095D5BD9B56518264A9A,
        EXPECTED_AM_LANE_13 = 120'hC39731333C68CECCD9B56514264A9A,
        EXPECTED_AM_LANE_14 = 120'hA6FBCA4E590435B1D9B565D0264A9A,
        EXPECTED_AM_LANE_15 = 120'h79BAA6A986455956D9B565B4264A9A;

    // índices para ordenar las líneas
    localparam [AM_LANES_WIDTH : 0]
        AM_LANE_0  = 4'h0,
        AM_LANE_1  = 4'h1,
        AM_LANE_2  = 4'h2,
        AM_LANE_3  = 4'h3,
        AM_LANE_4  = 4'h4,
        AM_LANE_5  = 4'h5,
        AM_LANE_6  = 4'h6,
        AM_LANE_7  = 4'h7,
        AM_LANE_8  = 4'h8,
        AM_LANE_9  = 4'h9,
        AM_LANE_10 = 4'hA,
        AM_LANE_11 = 4'hB,
        AM_LANE_12 = 4'hC,
        AM_LANE_13 = 4'hD,
        AM_LANE_14 = 4'hE,
        AM_LANE_15 = 4'hF;

    // Alignment markers esperados segun estandar
    logic [AM_WIDTH              - 1 : 0] expected_am     [0 : AM_LANES - 1];    // 16 vias de 120 bits cada una
    logic [AM_WIDTH              - 1 : 0] extracted_am    [0 : AM_LANES - 1];    // Registros para los primeros 120 bits de cada lane
    logic [LANE_WIDTH            - 1 : 0] stored_lanes    [0 : AM_LANES - 1];    // Registros para almacenar cada lane
    
    // Para almacenar los valores de extracted_am de la iteración anterior, se usa para sincronizar 
    logic [AM_WIDTH              - 1 : 0] last_am         [0 : AM_LANES - 1];
    logic [AM_LANES              - 1 : 0] sync_lanes; // Bandera de sincronización para cada lane 
    logic [AM_LANES            - 1 : 0] expected_am_flag;

    // Esto es para identificar que lane es cual
    logic [LANE_WIDTH-1:0] sorted_lanes [0:AM_LANES-1];
    logic [3:0] lane_mapping [0:AM_LANES-1];
    logic mapping_complete;

    // Contadores de ciclos entre activaciones de sync_lane
    logic [TOTAL_CYCLES_WIDTH    - 1 : 0] cycle_counter   [0 : AM_LANES - 1];   // Contador actual de ciclos para cada lane
    logic [TOTAL_CYCLES_WIDTH    - 1 : 0] cycle_gap       [0 : AM_LANES - 1];       // Valor del gap calculado entre activaciones de cada lane
    logic [AM_LANES              - 1 : 0] gap_error_flag;         // Bandera de error para gaps diferentes a 8191
    logic [AM_LANES              - 1 : 0] has_synced;             // Indica si un lane ya ha sido sincronizado al menos una vez
    
    // Codewords A, B, C y D con AM y FEC
    logic [CODEWORD_WIDTH        - 1 : 0] codeword_a;
    logic [CODEWORD_WIDTH        - 1 : 0] codeword_b;
    logic [CODEWORD_WIDTH        - 1 : 0] codeword_c;
    logic [CODEWORD_WIDTH        - 1 : 0] codeword_d;

    // Codewords A, B, C y D con AM y sin FEC
    logic [CODEWORD_WIDTH_WO_FEC - 1 : 0] codeword_a_wo_fec;
    logic [CODEWORD_WIDTH_WO_FEC - 1 : 0] codeword_b_wo_fec;
    logic [CODEWORD_WIDTH_WO_FEC - 1 : 0] codeword_c_wo_fec;
    logic [CODEWORD_WIDTH_WO_FEC - 1 : 0] codeword_d_wo_fec;
    
    // Tx scrambled 0 y 1
    logic [BLOCK_W_AM_WIDTH      - 1 : 0] tx_scrambled_0;
    logic [BLOCK_W_AM_WIDTH      - 1 : 0] tx_scrambled_1;
    
    // Tx scrambled 0 y 1 sin AM
    logic [BLOCK_WO_AM_WIDTH     - 1 : 0] tx_scrambled_0_wo_am;
    logic [BLOCK_WO_AM_WIDTH     - 1 : 0] tx_scrambled_1_wo_am;
    
    // AM mapped
    logic [AM_MAPPED_WIDTH       - 1 : 0] am_mapped_0;
    logic [AM_MAPPED_WIDTH       - 1 : 0] am_mapped_1;

    // Guardamos los valores de AM parametrizado en el registro usado en la comparación
    assign expected_am[AM_LANE_0 ]  = EXPECTED_AM_LANE_0;
    assign expected_am[AM_LANE_1 ]  = EXPECTED_AM_LANE_1;
    assign expected_am[AM_LANE_2 ]  = EXPECTED_AM_LANE_2;
    assign expected_am[AM_LANE_3 ]  = EXPECTED_AM_LANE_3;
    assign expected_am[AM_LANE_4 ]  = EXPECTED_AM_LANE_4;
    assign expected_am[AM_LANE_5 ]  = EXPECTED_AM_LANE_5;
    assign expected_am[AM_LANE_6 ]  = EXPECTED_AM_LANE_6;
    assign expected_am[AM_LANE_7 ]  = EXPECTED_AM_LANE_7;
    assign expected_am[AM_LANE_8 ]  = EXPECTED_AM_LANE_8;
    assign expected_am[AM_LANE_9 ]  = EXPECTED_AM_LANE_9;
    assign expected_am[AM_LANE_10] = EXPECTED_AM_LANE_10;
    assign expected_am[AM_LANE_11] = EXPECTED_AM_LANE_11;
    assign expected_am[AM_LANE_12] = EXPECTED_AM_LANE_12;
    assign expected_am[AM_LANE_13] = EXPECTED_AM_LANE_13;
    assign expected_am[AM_LANE_14] = EXPECTED_AM_LANE_14;
    assign expected_am[AM_LANE_15] = EXPECTED_AM_LANE_15;

    // Idem con las banderas de sincronización que indican que hay presencia de un AM
    assign sync_lanes [AM_LANE_0 ] = sync_lane_0;
    assign sync_lanes [AM_LANE_1 ] = sync_lane_1;
    assign sync_lanes [AM_LANE_2 ] = sync_lane_2;
    assign sync_lanes [AM_LANE_3 ] = sync_lane_3;
    assign sync_lanes [AM_LANE_4 ] = sync_lane_4;
    assign sync_lanes [AM_LANE_5 ] = sync_lane_5;
    assign sync_lanes [AM_LANE_6 ] = sync_lane_6;
    assign sync_lanes [AM_LANE_7 ] = sync_lane_7;
    assign sync_lanes [AM_LANE_8 ] = sync_lane_8;
    assign sync_lanes [AM_LANE_9 ] = sync_lane_9;
    assign sync_lanes [AM_LANE_10] = sync_lane_10;
    assign sync_lanes [AM_LANE_11] = sync_lane_11;
    assign sync_lanes [AM_LANE_12] = sync_lane_12;
    assign sync_lanes [AM_LANE_13] = sync_lane_13;
    assign sync_lanes [AM_LANE_14] = sync_lane_14;
    assign sync_lanes [AM_LANE_15] = sync_lane_15;
    
    always_comb begin
        

        // Verifico si han sido ordenados los lanes, sino uso la información tal cual viene
        if (!mapping_complete) begin
            stored_lanes[AM_LANE_0 ] = i_lane_0;
            stored_lanes[AM_LANE_1 ] = i_lane_1;
            stored_lanes[AM_LANE_2 ] = i_lane_2;
            stored_lanes[AM_LANE_3 ] = i_lane_3;
            stored_lanes[AM_LANE_4 ] = i_lane_4;
            stored_lanes[AM_LANE_5 ] = i_lane_5;
            stored_lanes[AM_LANE_6 ] = i_lane_6;
            stored_lanes[AM_LANE_7 ] = i_lane_7;
            stored_lanes[AM_LANE_8 ] = i_lane_8;
            stored_lanes[AM_LANE_9 ] = i_lane_9;
            stored_lanes[AM_LANE_10] = i_lane_10;
            stored_lanes[AM_LANE_11] = i_lane_11;
            stored_lanes[AM_LANE_12] = i_lane_12;
            stored_lanes[AM_LANE_13] = i_lane_13;
            stored_lanes[AM_LANE_14] = i_lane_14;
            stored_lanes[AM_LANE_15] = i_lane_15;
        end 
        // Si los lanes ya han sido ordenados, utilizo orden segun lane_mapping
        else begin
            stored_lanes[lane_mapping[0] ] = i_lane_0;
            stored_lanes[lane_mapping[1] ] = i_lane_1;
            stored_lanes[lane_mapping[2] ] = i_lane_2;
            stored_lanes[lane_mapping[3] ] = i_lane_3;
            stored_lanes[lane_mapping[4] ] = i_lane_4;
            stored_lanes[lane_mapping[5] ] = i_lane_5;
            stored_lanes[lane_mapping[6] ] = i_lane_6;
            stored_lanes[lane_mapping[7] ] = i_lane_7;
            stored_lanes[lane_mapping[8] ] = i_lane_8;
            stored_lanes[lane_mapping[9] ] = i_lane_9;
            stored_lanes[lane_mapping[10]] = i_lane_10;
            stored_lanes[lane_mapping[11]] = i_lane_11;
            stored_lanes[lane_mapping[12]] = i_lane_12;
            stored_lanes[lane_mapping[13]] = i_lane_13;
            stored_lanes[lane_mapping[14]] = i_lane_14;
            stored_lanes[lane_mapping[15]] = i_lane_15;
        end
        
        // Cargar los valores solo si el sync_lane correspondiente está activo
        // Extraer los últimos 120 bits de cada lane si el sync_lane correspondiente está en 1
        extracted_am[AM_LANE_0 ] = sync_lane_0  ? stored_lanes[AM_LANE_0 ][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_1 ] = sync_lane_1  ? stored_lanes[AM_LANE_1 ][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_2 ] = sync_lane_2  ? stored_lanes[AM_LANE_2 ][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_3 ] = sync_lane_3  ? stored_lanes[AM_LANE_3 ][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_4 ] = sync_lane_4  ? stored_lanes[AM_LANE_4 ][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_5 ] = sync_lane_5  ? stored_lanes[AM_LANE_5 ][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_6 ] = sync_lane_6  ? stored_lanes[AM_LANE_6 ][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_7 ] = sync_lane_7  ? stored_lanes[AM_LANE_7 ][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_8 ] = sync_lane_8  ? stored_lanes[AM_LANE_8 ][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_9 ] = sync_lane_9  ? stored_lanes[AM_LANE_9 ][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_10] = sync_lane_10 ? stored_lanes[AM_LANE_10][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_11] = sync_lane_11 ? stored_lanes[AM_LANE_11][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_12] = sync_lane_12 ? stored_lanes[AM_LANE_12][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_13] = sync_lane_13 ? stored_lanes[AM_LANE_13][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_14] = sync_lane_14 ? stored_lanes[AM_LANE_14][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        extracted_am[AM_LANE_15] = sync_lane_15 ? stored_lanes[AM_LANE_15][AM_WIDTH - 1 : 0]  : {AM_WIDTH{1'b0}};
        
        // Comparo AMs uno por uno, recibidos con los codificados, para saber si alguna lane recibe un AM incorrecto
        for (int i = 0; i < AM_LANES; i = i + 1'b1) begin
            expected_am_flag[i] = 1'b0;  // Inicializar en 0
            for (int j = 0; j < AM_LANES; j = j + 1'b1) begin
                if (extracted_am[i] == expected_am[j]) begin
                    expected_am_flag[i] = 1'b1;
                end
            end
        end
        
        // guardar los AM para comparar con la proxima vez
        last_am = extracted_am;

        // mux 10 bits para Round Robin
        for(int i = 0; i < TOTAL_ITERATIONS; i = i + 1'b1) begin
            for(int j = 0; j < AM_LANES; j = j + 1'b1) begin
                for(int k = 0; k < TOTAL_CODEWORDS; k = k + 1'b1) begin
                    case(k % 4)
                        2'h0: codeword_a[((CODEWORD_WIDTH / ROUND_ROBIN_BITS - (AM_LANES * i)) - j) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS] =
                                stored_lanes[j][(TOTAL_CODEWORDS * i + (k+1)) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
                        2'h1: codeword_b[((CODEWORD_WIDTH / ROUND_ROBIN_BITS - (AM_LANES * i)) - j) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS] =
                                stored_lanes[j][(TOTAL_CODEWORDS * i + (k+1)) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
                        2'h2: codeword_c[((CODEWORD_WIDTH / ROUND_ROBIN_BITS - (AM_LANES * i)) - j) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS] =
                                stored_lanes[j][(TOTAL_CODEWORDS * i + (k+1)) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
                        2'h3: codeword_d[((CODEWORD_WIDTH / ROUND_ROBIN_BITS - (AM_LANES * i)) - j) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS] =
                                stored_lanes[j][(TOTAL_CODEWORDS * i + (k+1)) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
                    endcase
                end
            end
        end

        // Extrae las codewords sin FEC
        codeword_a_wo_fec = codeword_a[CODEWORD_WIDTH - 1 -: CODEWORD_WIDTH_WO_FEC];
        codeword_b_wo_fec = codeword_b[CODEWORD_WIDTH - 1 -: CODEWORD_WIDTH_WO_FEC];
        codeword_c_wo_fec = codeword_c[CODEWORD_WIDTH - 1 -: CODEWORD_WIDTH_WO_FEC];
        codeword_d_wo_fec = codeword_d[CODEWORD_WIDTH - 1 -: CODEWORD_WIDTH_WO_FEC];

        // Usa round robin para obtener los datos de entrada
        for(int i = 0; i < CODEWORD_WIDTH_WO_FEC / ROUND_ROBIN_BITS; i = i + 1'b1) begin
            tx_scrambled_0[(2* i * ROUND_ROBIN_BITS) + 9  -: ROUND_ROBIN_BITS] = codeword_a_wo_fec[(CODEWORD_WIDTH_WO_FEC / ROUND_ROBIN_BITS - i) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
            tx_scrambled_0[(2* i * ROUND_ROBIN_BITS) + 19 -: ROUND_ROBIN_BITS] = codeword_b_wo_fec[(CODEWORD_WIDTH_WO_FEC / ROUND_ROBIN_BITS - i) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
            tx_scrambled_1[(2* i * ROUND_ROBIN_BITS) + 9  -: ROUND_ROBIN_BITS] = codeword_c_wo_fec[(CODEWORD_WIDTH_WO_FEC / ROUND_ROBIN_BITS - i) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
            tx_scrambled_1[(2* i * ROUND_ROBIN_BITS) + 19 -: ROUND_ROBIN_BITS] = codeword_d_wo_fec[(CODEWORD_WIDTH_WO_FEC / ROUND_ROBIN_BITS - i) * ROUND_ROBIN_BITS - 1 -: ROUND_ROBIN_BITS];
        end

        // Elimina los AM
        tx_scrambled_0_wo_am = tx_scrambled_0[BLOCK_W_AM_WIDTH - 1 -: BLOCK_WO_AM_WIDTH];
        tx_scrambled_1_wo_am = tx_scrambled_1[BLOCK_W_AM_WIDTH - 1 -: BLOCK_WO_AM_WIDTH];
        am_mapped_0          = tx_scrambled_0[AM_MAPPED_WIDTH  - 1  :                 0];
        am_mapped_1          = tx_scrambled_1[AM_MAPPED_WIDTH  - 1  :                 0];

    end

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reiniciar el mapeo de lanes
            mapping_complete <= 0;
            for (int i = 0; i < AM_LANES; i++) begin
                lane_mapping[i] <= 4'h0;
            end
            // Reiniciar los contadores, los gaps, las banderas de error y las señales de sincronización al reset
            for (int i = 0; i < AM_LANES - 1; i =  i + 1'b1) begin
                cycle_counter[i] <= {TOTAL_CYCLES_WIDTH {1'b0}};
                cycle_gap    [i] <= {TOTAL_CYCLES_WIDTH {1'b0}};
            end
            gap_error_flag <= {AM_LANES {1'b0}}; // Inicializar todas las banderas de error en 0
            has_synced     <= {AM_LANES {1'b0}};     // Inicializar las señales de sincronización en 0
        end else begin
        
            // Si los lanes no están mapeados, comienzo a detectarlos
            if (!mapping_complete) begin
                for (int i = 0; i < AM_LANES; i++) begin
                    for (int j = 0; j < AM_LANES; j++) begin
                        if (extracted_am[i] == expected_am[j]) begin
                            lane_mapping[j] <= i;
                        end
                    end
                end
                mapping_complete <= 1;
            end
            
            // Procesar cada línea de sincronización

            for(int i = 0; i < AM_LANES - 1; i = i + 1'b1) begin
                if (sync_lanes[i]) begin
                    cycle_gap [i] <= cycle_counter[i];
                    cycle_counter[i] <= {TOTAL_CYCLES_WIDTH{1'b0}};
                    if (has_synced[i] && cycle_counter[i] != TOTAL_CYCLES) begin
                        gap_error_flag[i] <= 1'b1; // Marcar error si el gap es diferente de 8191 y ya hubo una sincronización previa
                    end
                    has_synced[i] <= 1'b1; // Indicar que este lane ya fue sincronizado al menos una vez
                end else begin
                    cycle_counter[i] <= cycle_counter[i] + 1'b1;
                end
            end

        end
    end




endmodule