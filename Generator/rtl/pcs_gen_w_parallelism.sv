module PCS_generator_w_parallelism
#(              

    parameter NB_PAYLOAD_OUT           = 64                                                                                                                                                                                                                                                             , 
    parameter NB_HEADER_OUT            = 2                                                                                                                                                                                                                                                              , 
    parameter NB_CONTROL_CHAR          = 8                       /* Control width of 8 bits               */                                                                                                                                                                                            ,
    parameter N_PCS_WORDS_OUT          = 4                       /* Number of transcoder blocks           */                                                                                                                                                                                            ,
    parameter NB_FRAME_IN              = 257                     /* Transcoder width                      */                                                                                                                                                                                            ,
    parameter NB_TRANSCODER_HDR_OUT    = 4                       /* Transcoder header width               */                                                                                                                                                                                            ,
    parameter PROB                     = 5                       /* Probability of inserting control byte */                                                                                                                                                                                            ,                                                 
    parameter N_WORDS_PARALLELISM      = 8                                                                                                                                                                                                                                                              ,                                                                                                                                                                                                                                                
)               
(               
    output logic [NB_FRAME_IN       - 1 : 0] o_tx_coded [N_WORDS_PARALLELISM - 1 : 0] /* Output transcoder                      */                                                                                                                                                                      ,
    output logic [NB_PAYLOAD_OUT + NB_HEADER_OUT - 1 : 0] o_frame[N_PCS_WORDS_OUT - 1 : 0][N_WORDS_PARALLELISM - 1 : 0] /* Output frame */                                                                                                                                                              ,                              
    output logic [1                     : 0] o_valid [N_WORDS_PARALLELISM - 1 : 0] /* Output valid                           */                                                                                                                                                                         ,                                                            
    input  logic [NB_PAYLOAD_OUT    - 1 : 0] i_txd   [N_WORDS_PARALLELISM - 1 : 0] /* Input data                             */                                                                                                                                                                         ,
    input  logic [NB_CONTROL_CHAR   - 1 : 0] i_txc   [N_WORDS_PARALLELISM - 1 : 0] /* Input control byte                     */                                                                                                                                                                         ,
    input  logic [N_PCS_WORDS_OUT   - 1 : 0] i_data_sel [N_WORDS_PARALLELISM - 1 : 0]/* Data selector                          */                                                                                                                                                                       ,
    input  logic [1                     : 0] i_valid  [N_WORDS_PARALLELISM - 1 : 0] /* Input to enable frame generation       */                                                                                                                                                                        ,    
    input  logic                             i_enable [N_WORDS_PARALLELISM - 1 : 0] /* Flag to enable frame generation        */                                                                                                                                                                        ,
    input  logic                             i_random [N_WORDS_PARALLELISM - 1 : 0]  /* Flag to enable random frame generation */                                                                                                                                                                       ,
    input  logic                             i_tx_test_mode [N_WORDS_PARALLELISM - 1 : 0]      /* Flag to enable TX test mode            */                                                                                                                                                             ,
    input  logic                             i_rst_n             /* Reset                                  */                                                                                                                                                                                           ,    
    input  logic                             clk                 /* Clock                                  */                                                                                                                                                                                             

); 


genvar pcs_word;
generate
    for(pcs_word = 0; pcs_word < N_WORDS_PARALLELISM; pcs_word = pcs_word + 1'b1)
    begin
        PCS_generator #(
            .NB_PAYLOAD_OUT         (NB_PAYLOAD_OUT),
            .NB_HEADER_OUT          (NB_HEADER_OUT),
            .NB_CONTROL_CHAR        (NB_CONTROL_CHAR),
            .N_PCS_WORDS_OUT        (N_PCS_WORDS_OUT),
            .NB_FRAME_IN            (NB_FRAME_IN),
            .NB_TRANSCODER_HDR_OUT  (NB_TRANSCODER_HDR_OUT),
            .PROB                   (PROB)
        ) PCS_generator_inst (
            .o_tx_coded             (o_tx_coded[pcs_word]),
            .o_frame                (o_frame[pcs_word]),
            .o_valid                (o_valid[pcs_word]),
            .i_txd                  (i_txd[pcs_word]),
            .i_txc                  (i_txc[pcs_word]),
            .i_data_sel             (i_data_sel[pcs_word]),
            .i_valid                (i_valid[pcs_word]),
            .i_enable               (i_enable[pcs_word]),
            .i_random               (i_random[pcs_word]),
            .i_tx_test_mode         (i_tx_test_mode[pcs_word]),
            .i_rst_n                (i_rst_n),
            .clk                    (clk)
        );
    end
endgenerate

endmodule