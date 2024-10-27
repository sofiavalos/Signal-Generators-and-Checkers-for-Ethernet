module PCS_generator
#(
    
    parameter DATA_WIDTH           = 64                                                                                                                                                                                                                                             , 
    parameter HDR_WIDTH            = 2                                                                                                                                                                                                                                              , 
    parameter FRAME_WIDTH          = DATA_WIDTH + HDR_WIDTH  /* Frame width                           */                                                                                                                                                                            ,                                                                                                                                                                                             
    parameter CONTROL_WIDTH        = 8                       /* Control width of 8 bits               */                                                                                                                                                                            ,
    parameter TRANSCODER_BLOCKS    = 4                       /* Number of transcoder blocks           */                                                                                                                                                                            ,
    parameter TRANSCODER_WIDTH     = 257                     /* Transcoder width                      */                                                                                                                                                                            ,
    parameter TRANSCODER_HDR_WIDTH = 4                       /* Transcoder header width               */                                                                                                                                                                            ,
    parameter PROB                 = 5                       /* Probability of inserting control byte */                                                                                                                                                                            
)
(
    output logic [TRANSCODER_WIDTH  - 1 : 0] o_scrambler   /* Output scrambler                       */                                                                                                                                                                             ,
    output logic [TRANSCODER_WIDTH  - 1 : 0] o_transcoder  /* Output transcoder                      */                                                                                                                                                                             ,
    output logic [FRAME_WIDTH       - 1 : 0] o_frame_0     /* Output frame 0                         */                                                                                                                                                                             ,
    output logic [FRAME_WIDTH       - 1 : 0] o_frame_1     /* Output frame 1                         */                                                                                                                                                                             ,
    output logic [FRAME_WIDTH       - 1 : 0] o_frame_2     /* Output frame 2                         */                                                                                                                                                                             ,
    output logic [FRAME_WIDTH       - 1 : 0] o_frame_3     /* Output frame 3                         */                                                                                                                                                                             ,
    input  logic [TRANSCODER_BLOCKS - 1 : 0] i_data_sel    /* Data selector                          */                                                                                                                                                                             ,
    input  logic                             i_valid       /* Flag to enable frame generation        */                                                                                                                                                                             ,    
    input  logic                             i_random      /* Flag to enable random frame generation */                                                                                                                                                                             ,
    input  logic                             i_rst_n       /* Reset                                  */                                                                                                                                                                             ,    
    input  logic                             clk           /* Clock                                  */                                                                                                                                                                             
    
);

localparam [HDR_WIDTH - 1 : 0]
    DATA_SYNC = 2'b10 /* Data sync    */                                                                                                                                                                                                                                            ,
    CTRL_SYNC = 2'b01 /* Control sync */                                                                                                                                                                                                                                            ;

localparam [CONTROL_WIDTH - 1 : 0]
    CTRL_IDLE  = 8'h00   /* Control idle     */                                                                                                                                                                                                                                     ,
    CTRL_LPI   = 8'h01   /* Control LPI      */                                                                                                                                                                                                                                     ,
    CTRL_ERROR = 8'h1E   /* Control error    */                                                                                                                                                                                                                                     ,
    CTRL_SEQ   = 8'h4B   /* Control sequence */                                                                                                                                                                                                                                     ;
    
    
localparam [DATA_WIDTH - 1 : 0]
    FIXED_PATTERN_0 = 64'hAAAAAAAAAAAAAAAA                                                                                                                                                                                                                                          ,
    FIXED_PATTERN_1 = 64'h3333333333333333                                                                                                                                                                                                                                          ,
    FIXED_PATTERN_2 = 64'hFFFFFFFFFFFFFFFF                                                                                                                                                                                                                                          ,
    FIXED_PATTERN_3 = 64'h0000000000000000                                                                                                                                                                                                                                          ;
    
// Local variables
logic [FRAME_WIDTH      - 1 : 0] frame_reg_0    /* Frame register */                                                                                                                                                                                                                ;
logic [FRAME_WIDTH      - 1 : 0] frame_reg_1    /* Frame register */                                                                                                                                                                                                                ;
logic [FRAME_WIDTH      - 1 : 0] frame_reg_2    /* Frame register */                                                                                                                                                                                                                ;
logic [FRAME_WIDTH      - 1 : 0] frame_reg_3    /* Frame register */                                                                                                                                                                                                                ;
logic [TRANSCODER_WIDTH - 1 : 0] transcoder_reg /* Transcoder register */                                                                                                                                                                                                           ;
logic [TRANSCODER_WIDTH - 1 : 0] scrambled_data_reg /* Scrambled data */                                                                                                                                                                                                            ; 
logic [TRANSCODER_WIDTH - 1 : 0] lfsr_value     /* Value of LFSR */                                                                                                                                                                                                                 ;

// Task to generate a PCS frame
task automatic generate_frame(
    output logic [FRAME_WIDTH - 1 : 0] o_frame      /* Output frame */                                                                                                                                                                                                              ,
    input  int                         i_number       /* Random number */                                                                                                                                                                                                             
)                                                                                                                                                                                                                                                                                   ;
    logic [DATA_WIDTH    - 1 : 0] data_block       /* Block of data */                                                                                                                                                                                                              ; 
    logic [CONTROL_WIDTH - 1 : 0] control_byte     /* Control byte */                                                                                                                                                                                                               ;             
    automatic int                 insert_control   /* Flag to insert control byte */                                                                                                                                                                                                ;                       

    // Generate a random data block
    data_block = $urandom($time + i_number) % 64'hFFFFFFFFFFFFFFFF                                                                                                                                                                                                                  ;                                            

    // Decide wheter insert control byte or not
    insert_control = $urandom($time + i_number) % 100                                                                                                                                                                                                                               ;

    // Create the frame
    if (insert_control < PROB) begin
        // Choose a random control byte between 0 to 3
        case ($urandom($time + i_number) % 3)
            0: control_byte = CTRL_IDLE                                                                                                                                                                                                                                             ;
            1: control_byte = CTRL_LPI                                                                                                                                                                                                                                              ;
            2: control_byte = CTRL_ERROR                                                                                                                                                                                                                                            ;
            3: control_byte = CTRL_SEQ                                                                                                                                                                                                                                              ;
        endcase
        // Choose a byte position to insert control byte
        data_block[(($urandom($time + i_number) % 7 + 1) * 8 - 1) -: 8] = control_byte                                                                                                                                                                                              ;  
        // Use control sync if control byte is inserted
        o_frame = {CTRL_SYNC, data_block}                                                                                                                                                                                                                                           ; 
    end else begin
         // Use data sync if no control byte
        o_frame = {DATA_SYNC, data_block}                                                                                                                                                                                                                                           ;
    end
endtask

task automatic encode_frame(
    output logic[TRANSCODER_WIDTH - 1 : 0] o_transcoder
)                                                                                                                                                                                                                                                                                   ;                                      
    // transcoder output
    logic [TRANSCODER_WIDTH     - 1 : 0] transcoder                                                                                                                                                                                                                                 ; 
    // transcoder control header
    logic [TRANSCODER_HDR_WIDTH - 1 : 0] transcoder_control_hdr                                                                                                                                                                                                                     ;
    // transcoder header
    logic                                transcoder_hdr                                                                                                                                                                                                                             ;                                    
    
    // Check if the frame is a control frame
    if((frame_reg_0[FRAME_WIDTH - 1 -: 2] == DATA_SYNC) && (frame_reg_1[FRAME_WIDTH - 1 -: 2] == DATA_SYNC) && (frame_reg_2[FRAME_WIDTH - 1 -: 2] == DATA_SYNC) && (frame_reg_3[FRAME_WIDTH - 1 -: 2] == DATA_SYNC)) begin
        // Data frame with header as 1
        transcoder = {1'b1, frame_reg_0[DATA_WIDTH - 1 : 0], frame_reg_1[DATA_WIDTH - 1 : 0], frame_reg_2[DATA_WIDTH - 1 : 0], frame_reg_3[DATA_WIDTH - 1 : 0]}                                                                                                                     ;                                                                                                                                                                                                                   ;
    end
    else begin
        // Control frame with header as 0
        transcoder_hdr = 1'b0                                                                                                                                                                                                                                                       ;
        transcoder_control_hdr = {(frame_reg_0[FRAME_WIDTH - 1 -: 2] == DATA_SYNC), (frame_reg_1[FRAME_WIDTH - 1 -: 2] == DATA_SYNC), (frame_reg_2[FRAME_WIDTH - 1 -: 2] == DATA_SYNC), (frame_reg_3[FRAME_WIDTH - 1 -: 2] == DATA_SYNC)}                                           ;
        transcoder = (frame_reg_0[FRAME_WIDTH-1 -: 2] == CTRL_SYNC) ? {transcoder_hdr, transcoder_control_hdr, frame_reg_0[DATA_WIDTH - 1 -: 4], frame_reg_0[DATA_WIDTH - 9 : 0],frame_reg_1[DATA_WIDTH - 1 : 0], frame_reg_2[DATA_WIDTH - 1 : 0], frame_reg_3[DATA_WIDTH - 1 : 0]} :
                     (frame_reg_1[FRAME_WIDTH-1 -: 2] == CTRL_SYNC) ? {transcoder_hdr, transcoder_control_hdr, frame_reg_0[DATA_WIDTH - 1 : 0], frame_reg_1[DATA_WIDTH - 1 -: 4],frame_reg_1[DATA_WIDTH - 9 : 0], frame_reg_2[DATA_WIDTH - 1 : 0], frame_reg_3[DATA_WIDTH - 1 : 0]} :
                     (frame_reg_2[FRAME_WIDTH-1 -: 2] == CTRL_SYNC) ? {transcoder_hdr, transcoder_control_hdr, frame_reg_0[DATA_WIDTH - 1 : 0], frame_reg_1[DATA_WIDTH - 1 : 0],frame_reg_2[DATA_WIDTH - 1 -: 4], frame_reg_2[DATA_WIDTH - 9 : 0], frame_reg_3[DATA_WIDTH - 1 : 0]} :
                                                                      {transcoder_hdr, transcoder_control_hdr, frame_reg_0[DATA_WIDTH - 1 : 0], frame_reg_1[DATA_WIDTH - 1 : 0],frame_reg_2[DATA_WIDTH - 1 : 0], frame_reg_3[DATA_WIDTH - 1 -: 4], frame_reg_3[DATA_WIDTH - 9 : 0]} ;
    end  
    o_transcoder = transcoder                                                                                                                                                                                                                                                       ;                                                                                                                                                                                                                   ;
endtask


task automatic scrambler(        
    output logic [TRANSCODER_WIDTH - 1 : 0] scrambled_data /* Output data scrambled */                                                                                                                                                                                              
)                                                                                                                                                                                                                                                                                   ;
    logic [FRAME_WIDTH - 1 : 0] data_scrambled /* Data scrambled */                                                                                                                                                                                                                 ;

    begin
        // Scrambler LFSR
        for (int i = 0; i < TRANSCODER_WIDTH - 1; i++) begin
            data_scrambled[i] = transcoder_reg[i] ^ lfsr_value[FRAME_WIDTH - 1] /* XOR data with LFSR output */                                                                                                                                                                     ;         
            lfsr_value        = {lfsr_value[FRAME_WIDTH - 2 : 0], lfsr_value[FRAME_WIDTH] ^ lfsr_value[217] ^ lfsr_value[198]} /* Use polynomial 1 + x^39 + x^56 */                                                                                                                 ;         
        end
        // Last bit of LFSR
        data_scrambled[FRAME_WIDTH - 1] = lfsr_value[FRAME_WIDTH - 1]                                                                                                                                                                                                               ;
        // Output scrambled data
        scrambled_data = data_scrambled                                                                                                                                                                                                                                             ;            
    end

endtask


// Frame generation process
always_ff @(posedge clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        // Reset all frame registers
        frame_reg_0    <= 'b0                                                                                                                                                                                                                                                       ;                                                                                             
        frame_reg_1    <= 'b0                                                                                                                                                                                                                                                       ;                                                                                             
        frame_reg_2    <= 'b0                                                                                                                                                                                                                                                       ;                                                                                             
        frame_reg_3    <= 'b0                                                                                                                                                                                                                                                       ;                                                                                             
        transcoder_reg <= 'b0                                                                                                                                                                                                                                                       ;                                                                                             
        scrambled_data_reg <= 'b0                                                                                                                                                                                                                                                   ;
        lfsr_value     <= {TRANSCODER_WIDTH {1'b1}}                                                                                                                                                                                                                                 ;
    end 
    else if(i_valid) begin
        if(i_random) begin
            // Generate frames for each output
            generate_frame(frame_reg_0, 043)                                                                                                                                                                                                                                        ;
            generate_frame(frame_reg_1, 086)                                                                                                                                                                                                                                        ;
            generate_frame(frame_reg_2, 127)                                                                                                                                                                                                                                        ;
            generate_frame(frame_reg_3, 065)                                                                                                                                                                                                                                        ;
       end
       else begin
            frame_reg_0 <= {((i_data_sel[0] == 1) ? DATA_SYNC : CTRL_SYNC), FIXED_PATTERN_0}                                                                                                                                                                                        ;
            frame_reg_1 <= {((i_data_sel[1] == 1) ? DATA_SYNC : CTRL_SYNC), FIXED_PATTERN_1}                                                                                                                                                                                        ;
            frame_reg_2 <= {((i_data_sel[2] == 1) ? DATA_SYNC : CTRL_SYNC), FIXED_PATTERN_2}                                                                                                                                                                                        ;
            frame_reg_3 <= {((i_data_sel[3] == 1) ? DATA_SYNC : CTRL_SYNC), FIXED_PATTERN_3}                                                                                                                                                                                        ;
       end
       encode_frame(transcoder_reg)                                                                                                                                                                                                                                                 ;
       scrambler(scrambled_data_reg)                                                                                                                                                                                                                                                ;
    end
    else begin
        // Keep the last frame if no valid input
        frame_reg_0    <= frame_reg_0                                                                                                                                                                                                                                               ;      
        frame_reg_1    <= frame_reg_1                                                                                                                                                                                                                                               ;      
        frame_reg_2    <= frame_reg_2                                                                                                                                                                                                                                               ;      
        frame_reg_3    <= frame_reg_3                                                                                                                                                                                                                                               ;      
        transcoder_reg <= transcoder_reg                                                                                                                                                                                                                                            ;      
        scrambled_data_reg <= scrambled_data_reg                                                                                                                                                                                                                                    ;
        lfsr_value     <= lfsr_value                                                                                                                                                                                                                                                ;
    end
end

assign o_frame_0    = frame_reg_0                                                                                                                                                                                                                                                   ;   
assign o_frame_1    = frame_reg_1                                                                                                                                                                                                                                                   ;   
assign o_frame_2    = frame_reg_2                                                                                                                                                                                                                                                   ;   
assign o_frame_3    = frame_reg_3                                                                                                                                                                                                                                                   ;   
assign o_transcoder = transcoder_reg                                                                                                                                                                                                                                                ;   
assign o_scrambler  = scrambled_data_reg;

endmodule
