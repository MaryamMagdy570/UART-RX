module RX_Deserializer
(
  input wire          CLK,
  input wire          RST,
  input wire          Deserializer_Enable,
  input wire          Sampled_Bit,
  output reg  [7:0]   Parallel_data
);

reg  [7:0]   Parallel_data_comb;

always @ (posedge CLK or negedge RST)
  begin
    if(!RST)
      begin
        Parallel_data <= 8'b0;
      end
    else 
      begin
        Parallel_data <= Parallel_data_comb;
      end
  end


always @ (*)
  begin
    if(Deserializer_Enable)
      begin
        Parallel_data_comb = {Sampled_Bit,Parallel_data[7:1]};
      end
    else
      begin
        Parallel_data_comb = Parallel_data;
      end

  end




endmodule