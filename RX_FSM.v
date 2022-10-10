module RX_FSM 
(
  input wire          CLK,
  input wire          RST,
  input wire          Parity_Enable,
  input wire          Serial_Data,
  input wire  [3:0]   Bit_Counts,
  input wire  [2:0]   Edge_Counts,
  input wire          Parity_Error,
  input wire          Start_Glitch,
  input wire          Stop_Error,

  output reg          Counter_Enable,
  output reg          Deserializer_Enable,
  output reg          DataSampler_Enable,
  output reg          ParityCheck_Enable,
  output reg          StartCheck_Enable,
  output reg          StopCheck_Enable,

  output reg          Data_Valid
);

localparam  IDLE = 3'b000,
            START = 3'b001,
            DATA = 3'b010,
            PARITY = 3'b011,
            STOP = 3'b100;


localparam EDGE3 = 3'd3,
           EDGE4 = 3'd4,
           EDGE5 = 3'd5,
           EDGE7 = 3'd7,
           EDGE0 = 3'd0;


reg [2:0] Current_State;
reg [2:0] Current_State_comb;


always @ (posedge CLK or negedge RST)
  begin
    if(!RST)
      begin
        Current_State <= IDLE;
      end
    else
      begin
        Current_State <= Current_State_comb;
      end
  end


always @ (*)
  begin
    case(Current_State)
      IDLE:   begin
                if(!Serial_Data && !Bit_Counts)
                  begin
                    Current_State_comb = START;
                  end          
                else
                  begin
                    Current_State_comb = IDLE;
                  end
              end
      START:  begin
                if(Bit_Counts == 4'd1 && Start_Glitch)
                  begin
                    Current_State_comb = IDLE;  
                  end
                else if (Bit_Counts == 4'd1 && !Start_Glitch)
                  begin
                    Current_State_comb = DATA;
                  end
                else
                  begin
                    Current_State_comb = START;
                  end
              end
      DATA:   begin
                if(Bit_Counts == 4'd9 && Parity_Enable) 
                  begin
                    Current_State_comb = PARITY;
                  end
                else if(Bit_Counts == 4'd9 && !Parity_Enable)
                  begin
                    Current_State_comb = STOP;
                  end
                else
                  begin
                    Current_State_comb = DATA;
                  end
              end
      PARITY: begin
                if (Bit_Counts == 4'd10)
                  begin
                    Current_State_comb = STOP;
                  end
                else
                  begin
                    Current_State_comb = PARITY;
                  end
              end
      STOP:   begin
                if (Serial_Data && ((Bit_Counts == 4'd11 && Parity_Enable) || (Bit_Counts == 4'd10 && !Parity_Enable)))
                  begin
                    Current_State_comb = IDLE;
                  end
                else if (!Serial_Data && ((Bit_Counts == 4'd11 && Parity_Enable) || (Bit_Counts == 4'd10 && !Parity_Enable)))
                  begin
                    Current_State_comb = START;
                  end
                else
                  begin
                    Current_State_comb = STOP;
                  end
              end
      default:begin
                Current_State_comb = IDLE;  
              end
    endcase
  end



always @ (*)
  begin
    Counter_Enable = 0;
    ParityCheck_Enable = 0;
    StartCheck_Enable = 0;
    StopCheck_Enable = 0;
    DataSampler_Enable = 0;
    Deserializer_Enable = 0;
    Data_Valid = 0;
    case(Current_State)
      IDLE:   begin
                //no changes
              end
      START:  begin
                Counter_Enable = 1;
                case(Edge_Counts)
                  EDGE3:    begin
                              DataSampler_Enable = 1;
                            end
                  EDGE4:    begin
                              DataSampler_Enable = 1;
                            end
                  EDGE5:    begin
                              DataSampler_Enable = 1;
                            end
                  EDGE7:    begin
                              StartCheck_Enable = 1;
                            end
                  default:  begin
                              DataSampler_Enable = 0;
                              Deserializer_Enable = 0;
                              StartCheck_Enable = 0;
                            end
                endcase
              end
      DATA:   begin
                Counter_Enable = 1;
                case(Edge_Counts)
                  EDGE3:    begin
                              DataSampler_Enable = 1;
                            end
                  EDGE4:    begin
                              DataSampler_Enable = 1;
                            end
                  EDGE5:    begin
                              DataSampler_Enable = 1;
                            end
                  EDGE7:    begin
                              Deserializer_Enable = 1;
                              if(Parity_Enable)
                                begin
                                  ParityCheck_Enable = 1;
                                end 
                              else
                                begin
                                  ParityCheck_Enable = 0;
                                end
                            end
                  default:  begin
                              DataSampler_Enable = 0;
                              Deserializer_Enable = 0;
                              ParityCheck_Enable = 0;
                            end
                endcase
              end
      PARITY: begin
                Counter_Enable = 1;
                case(Edge_Counts)
                  EDGE3:    begin
                              DataSampler_Enable = 1;
                            end
                  EDGE4:    begin
                              DataSampler_Enable = 1;
                            end
                  EDGE5:    begin
                              DataSampler_Enable = 1;
                            end
                  EDGE7:    begin
                              ParityCheck_Enable = 1;
                            end
                  default:  begin
                              DataSampler_Enable = 0;
                              ParityCheck_Enable = 0;
                            end
                endcase
              end
      STOP:   begin
                Counter_Enable = 1;
                case(Edge_Counts)
                  EDGE3:    begin
                              DataSampler_Enable = 1;
                            end
                  EDGE4:    begin
                              DataSampler_Enable = 1;
                            end
                  EDGE5:    begin
                              DataSampler_Enable = 1;
                            end
                  EDGE7:    begin
                              StopCheck_Enable = 1;
                            end
                  EDGE0:    begin
                              if(!Stop_Error && !Parity_Error && Parity_Enable)
                                begin
                                  Data_Valid = 1;
                                end
                              else if (!Stop_Error && !Parity_Enable)
                                begin
                                  Data_Valid = 1;
                                end
                              else
                                begin
                                  Data_Valid = 0;
                                end
                            end
                  default:  begin
                              DataSampler_Enable = 0;
                              StopCheck_Enable = 0;
                            end
                endcase
              end
      default:begin
                Counter_Enable = 0;
                ParityCheck_Enable = 0;
                StartCheck_Enable = 0;
                StopCheck_Enable = 0;
                DataSampler_Enable = 0;
                Deserializer_Enable = 0;
                Data_Valid = 0;
              end
    endcase
  end





endmodule