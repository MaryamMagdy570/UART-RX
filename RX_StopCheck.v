module  RX_StopCheck 
(
  input wire          CLK,
  input wire          RST,
  input wire          StopCheck_Enable,
  input wire          Sampled_Bit,
  output reg          Stop_Error
);

reg  Stop_Error_comb;

always @ (posedge CLK or negedge RST)
  begin
    if(!RST)
      begin
        Stop_Error <= 1'b0;
      end
    else 
      begin
        Stop_Error <= Stop_Error_comb;
      end
  end


always @ (*)
begin
  if(StopCheck_Enable && Sampled_Bit)
    begin
      Stop_Error_comb = 0;
    end
  else
    begin
      Stop_Error_comb = 1;
    end
end


endmodule