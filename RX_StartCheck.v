module  RX_StartCheck 
(
  input wire          CLK,
  input wire          RST,
  input wire          StartCheck_Enable,
  input wire          Sampled_Bit,
  output reg          Start_Glitch
);

reg  Start_Glitch_comb;

always @ (posedge CLK or negedge RST)
  begin
    if(!RST)
      begin
        Start_Glitch <= 1'b0;
      end
    else 
      begin
        Start_Glitch <= Start_Glitch_comb;
      end
  end


always @ (*)
begin
  if(StartCheck_Enable && !Sampled_Bit)
    begin
      Start_Glitch_comb = 0;
    end
  else
    begin
      Start_Glitch_comb = 1;
    end
end


endmodule