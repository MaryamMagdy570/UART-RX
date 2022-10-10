module RX_ParityCheck 
(
  input wire            RST,
  input wire            CLK,
  input wire            ParityCheck_Enable,
  input wire            Parity_Type,
  input wire            Sampled_Bit,
  input wire    [3:0]   Bit_Counts,   
  output reg            Parity_Error
);


reg [7:0]   Register;
reg [7:0]   Register_comb;
reg         ParityBit;
reg         ParityBit_comb;



localparam  EVEN = 0,
            ODD = 1;


always @ (posedge CLK or negedge RST)
  begin
    if(!RST)
      begin
        Register <= 8'b0;
        ParityBit <= 0;
      end
    else 
      begin
        Register <= Register_comb;
        ParityBit <= ParityBit_comb;
      end
  end


always @ (*)
  begin
    if(ParityCheck_Enable && Bit_Counts != 4'd9)        
      begin
        Register_comb = {Sampled_Bit,Register[7:1]} ;
        ParityBit_comb = ParityBit;
      end
    else if (ParityCheck_Enable && Bit_Counts == 4'd9) 
      begin
        Register_comb = Register;
        ParityBit_comb = Sampled_Bit;
      end
    else
      begin
        Register_comb = Register;
        ParityBit_comb = ParityBit;
      end   
  end

always @ (*)
begin
  if (Bit_Counts == 4'd10 || Bit_Counts == 4'd11)
    begin
      case (Parity_Type)
        EVEN: begin
                if (ParityBit == ^Register)
                  begin
                    Parity_Error = 0; 
                  end
                else
                  begin
                    Parity_Error = 1; 
                  end
              end
        ODD:  begin
                if (ParityBit == ~^Register)
                  begin
                    Parity_Error = 0; 
                  end
                else
                  begin
                    Parity_Error = 1; 
                  end
              end
        default:  begin
                    Parity_Error = 1;
                  end
      endcase
    end
  else
    begin
      Parity_Error = 1;
    end
end


endmodule