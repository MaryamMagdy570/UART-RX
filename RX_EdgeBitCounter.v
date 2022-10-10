module RX_EdgeBitCounter
(
  input wire            CLK,
  input wire            RST,
  input wire            Counter_Enable,
  input wire            Parity_Enable,
  output reg   [3:0]    Bit_Counts,  
  output reg   [2:0]    Edge_Counts
);

reg   [3:0]    Bit_Counts_comb; 
reg   [2:0]    Edge_Counts_comb;
wire  [3:0]    Counter_End;

assign Counter_End = Parity_Enable ? 4'd11 : 4'd10;


always @ (posedge CLK or negedge RST)
  begin
    if(!RST)
      begin
        Bit_Counts <= 3'b0;
        Edge_Counts <= 2'b0;
      end
    else 
      begin
        Bit_Counts <= Bit_Counts_comb;
        Edge_Counts <= Edge_Counts_comb;
      end
  end

always @ (*) 
  begin
    if (Counter_Enable)
      begin
        Edge_Counts_comb = Edge_Counts + 3'd1;
      end
    else
      begin
        Edge_Counts_comb = 3'd0;
      end
  end


always @ (*)
  begin
    if(Counter_Enable && Edge_Counts == 3'd7 && Bit_Counts != Counter_End)
      begin
        Bit_Counts_comb = Bit_Counts + 4'd1;
      end
    else if (Counter_Enable && Bit_Counts != Counter_End)
      begin
        Bit_Counts_comb = Bit_Counts;
      end
    else
      begin
        Bit_Counts_comb = 4'd0;
      end
  end


endmodule