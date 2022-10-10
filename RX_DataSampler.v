module RX_DataSampler
(
  input wire          CLK,
  input wire          RST,
  input wire          DataSampler_Enable,
  input wire   [2:0]  Edge_Counts,
  input wire          Serial_Data,
  input wire   [3:0]  PreScale,
  output reg          Sampled_Bit
);

reg [2:0]   Register;
reg [2:0]   Register_comb;
reg         Sampled_Bit_comb;


always @ (posedge CLK or negedge RST)
  begin
    if(!RST)
      begin
        Register <= 0;
        Sampled_Bit <= 0;
      end
    else
      begin
        Register <= Register_comb;
        Sampled_Bit <= Sampled_Bit_comb;
      end
  end



always @ (*)
  begin
    if(DataSampler_Enable)
      begin
        Register_comb = Register;
        case(Edge_Counts)
          ((PreScale>>1)-3'd1): begin
                                  Register_comb[0] = Serial_Data;
                                end
          ((PreScale>>1)):      begin
                                  Register_comb[1] = Serial_Data;
                                end
          ((PreScale>>1)+3'd1): begin
                                  Register_comb[2] = Serial_Data;
                                end
                      default:  begin
                                  Register_comb = Register;
                                end
        endcase
      end
    else
      begin
        Register_comb = Register;
      end
  end


always @(*) 
  begin
    if (Edge_Counts == (PreScale>>1)+3'd2)
      begin
        casex(Register)
        3'b00x: begin
                  Sampled_Bit_comb = 0;
                end
        3'bx00: begin
                  Sampled_Bit_comb = 0;
                end
        3'b0x0: begin
                  Sampled_Bit_comb = 0;
                end
        3'b11x: begin
                  Sampled_Bit_comb = 1;
                end
        3'bx11: begin
                  Sampled_Bit_comb = 1;
                end
        3'b1x1: begin
                  Sampled_Bit_comb = 1;
                end
        default: begin
                  Sampled_Bit_comb = Sampled_Bit;
                 end
        endcase
      end
    else
      begin
        Sampled_Bit_comb = Sampled_Bit;
      end
  end



endmodule