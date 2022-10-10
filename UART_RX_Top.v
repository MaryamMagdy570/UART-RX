module UART_RX_TOP
(
  input wire          RX_CLK,
  input wire          RX_RST,
  input wire          RX_Serial_Data,
  input wire          RX_Parity_Enable,
  input wire          RX_Parity_Type,
  input wire  [3:0]   RX_Prescale,
  output wire         RX_Data_Valid,        
  output wire [7:0]   RX_Parallel_Data        
);

wire          RX_DataSampler_Enable;
wire  [2:0]   RX_Edge_Counts;
wire  [3:0]   RX_Bit_Counts;
wire          RX_Sampled_Bit;
wire          RX_Deserializer_Enable;
wire          RX_Counter_Enable;
wire          RX_Parity_Error;
wire          RX_Start_Glitch;
wire          RX_Stop_Error;
wire          RX_ParityCheck_Enable;
wire          RX_StartCheck_Enable;
wire          RX_StopCheck_Enable;


RX_DataSampler u_RX_DataSampler(
  .CLK                (RX_CLK                ),
  .RST                (RX_RST                ),
  .DataSampler_Enable (RX_DataSampler_Enable ),
  .Edge_Counts        (RX_Edge_Counts        ),
  .Serial_Data        (RX_Serial_Data        ),
  .PreScale           (RX_Prescale           ),
  .Sampled_Bit        (RX_Sampled_Bit        )
);


RX_Deserializer u_RX_Deserializer(
  .CLK                 (RX_CLK                 ),
  .RST                 (RX_RST                 ),
  .Deserializer_Enable (RX_Deserializer_Enable ),
  .Sampled_Bit         (RX_Sampled_Bit         ),
  .Parallel_data       (RX_Parallel_Data        )
);

RX_EdgeBitCounter u_RX_EdgeBitCounter(
  .CLK            (RX_CLK            ),
  .RST            (RX_RST            ),
  .Counter_Enable (RX_Counter_Enable ),
  .Parity_Enable  (RX_Parity_Enable  ),
  .Bit_Counts     (RX_Bit_Counts     ),
  .Edge_Counts    (RX_Edge_Counts    )
);

RX_FSM  u_RX_FSM(
  .CLK                 (RX_CLK                 ),
  .RST                 (RX_RST                 ),
  .Parity_Enable       (RX_Parity_Enable       ),
  .Serial_Data         (RX_Serial_Data         ),
  .Bit_Counts          (RX_Bit_Counts          ),
  .Edge_Counts         (RX_Edge_Counts         ),
  .Parity_Error        (RX_Parity_Error        ),
  .Start_Glitch        (RX_Start_Glitch        ),
  .Stop_Error          (RX_Stop_Error          ),
  .Counter_Enable      (RX_Counter_Enable      ),
  .Deserializer_Enable (RX_Deserializer_Enable ),
  .DataSampler_Enable  (RX_DataSampler_Enable  ),
  .ParityCheck_Enable  (RX_ParityCheck_Enable  ),
  .StartCheck_Enable   (RX_StartCheck_Enable   ),
  .StopCheck_Enable    (RX_StopCheck_Enable    ),
  .Data_Valid          (RX_Data_Valid          )
);

RX_ParityCheck  u_RX_ParityCheck(
  .CLK                (RX_CLK                ),
  .RST                (RX_RST                ),
  .ParityCheck_Enable (RX_ParityCheck_Enable ),
  .Parity_Type        (RX_Parity_Type        ),
  .Sampled_Bit        (RX_Sampled_Bit        ),
  .Bit_Counts         (RX_Bit_Counts         ),
  .Parity_Error       (RX_Parity_Error       )
);

RX_StartCheck u_RX_StartCheck(
  .CLK               (RX_CLK               ),
  .RST               (RX_RST               ),
  .StartCheck_Enable (RX_StartCheck_Enable ),
  .Sampled_Bit       (RX_Sampled_Bit       ),
  .Start_Glitch      (RX_Start_Glitch      )
);

RX_StopCheck u_RX_StopCheck(
  .CLK              (RX_CLK              ),
  .RST              (RX_RST              ),
  .StopCheck_Enable (RX_StopCheck_Enable ),
  .Sampled_Bit      (RX_Sampled_Bit      ),
  .Stop_Error       (RX_Stop_Error       )
);



endmodule