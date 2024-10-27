
module PCS_generator_tb;

  // Parameters
  localparam  DATA_WIDTH = 64;
  localparam  HDR_WIDTH = 2;
  localparam  FRAME_WIDTH = DATA_WIDTH + HDR_WIDTH;
  localparam  CONTROL_WIDTH = 8;
  localparam  TRANSCODER_BLOCKS = 4;
  localparam  TRANSCODER_WIDTH = 257;
  localparam  TRANSCODER_HDR_WIDTH = 4;
  localparam  PROB =30;

  //Ports
  logic clk;
  logic i_rst_n;
  logic i_valid;
  logic i_random;
  logic [TRANSCODER_BLOCKS-1:0] i_data_sel;
  logic [FRAME_WIDTH-1:0] o_frame_0;
  logic [FRAME_WIDTH-1:0] o_frame_1;
  logic [FRAME_WIDTH-1:0] o_frame_2;
  logic [FRAME_WIDTH-1:0] o_frame_3;
  logic [TRANSCODER_WIDTH-1:0] o_transcoder;
  logic [TRANSCODER_WIDTH-1:0] o_scrambler;

  PCS_generator # (
    .DATA_WIDTH(DATA_WIDTH),
    .HDR_WIDTH(HDR_WIDTH),
    .FRAME_WIDTH(FRAME_WIDTH),
    .CONTROL_WIDTH(CONTROL_WIDTH),
    .TRANSCODER_BLOCKS(TRANSCODER_BLOCKS),
    .TRANSCODER_WIDTH(TRANSCODER_WIDTH),
    .TRANSCODER_HDR_WIDTH(TRANSCODER_HDR_WIDTH),
    .PROB(PROB)
  )
  PCS_generator_inst (
    .clk(clk),
    .i_rst_n(i_rst_n),
    .i_valid(i_valid),
    .i_random(i_random),
    .i_data_sel(i_data_sel),
    .o_frame_0(o_frame_0),
    .o_frame_1(o_frame_1),
    .o_frame_2(o_frame_2),
    .o_frame_3(o_frame_3),
    .o_transcoder(o_transcoder),
    .o_scrambler(o_scrambler)
  );

always #5  clk = ~clk ;

initial begin
    clk = 1'b0;
    i_rst_n = 1'b0;
    i_valid = 1'b0;
    i_random = 1'b0;
    i_data_sel = 4'b1111;
    #100;
    i_rst_n = 1'b1;
    i_valid = 1'b1;
    i_random = 1'b1;
    #1000;
    i_random = 1'b0;
    #100;
    i_data_sel = 4'b0001;
    #100;
    i_data_sel = 4'b0010;
    #100;
    i_data_sel = 4'b0011;
    #100;
    i_data_sel = 4'b0100;
    #100;
    i_data_sel = 4'b0101;
    #100;
    i_data_sel = 4'b0110;
    #100;
    i_data_sel = 4'b0111;
    #100;
    i_data_sel = 4'b1000;
    #100;
    i_data_sel = 4'b1001;
    #100;
    i_data_sel = 4'b1010;
    #100;
    i_data_sel = 4'b1011;
    #100;
    i_data_sel = 4'b1100;
    #100;
    i_data_sel = 4'b1101;
    #100;
    i_data_sel = 4'b1110;
    #100;
    i_valid = 1'b0;
    #100;
    $finish;
end


endmodule