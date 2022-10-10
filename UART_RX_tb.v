`timescale 1ns/1ps

module UART_RX_tb();

  reg          RX_CLK_tb;
  reg          RX_RST_tb;
  reg          RX_Serial_Data_tb;
  reg          RX_Parity_Enable_tb;
  reg          RX_Parity_Type_tb;
  reg  [3:0]   RX_Prescale_tb;
  wire         RX_Data_Valid_tb;        
  wire [7:0]   RX_Parallel_Data_tb;       


localparam CLK_SIZE = 5;


initial 
  begin
    //initial values
    RX_CLK_tb = 0;
    RX_Prescale_tb = 4'd8;
    RX_Serial_Data_tb = 1;
    RX_Parity_Enable_tb = 0;
    RX_Parity_Type_tb = 0;
    
    //reset
    RX_RST_tb = 1;
    #(CLK_SIZE/2.0)
    RX_RST_tb = 0;
    #(CLK_SIZE/2.0)
    RX_RST_tb = 1;

    #CLK_SIZE

    if (RX_Parallel_Data_tb == 8'd0 && RX_Data_Valid_tb == 0)
      $display ("pass0");
    else
      $display ("fail0");

/******************** case1: frame without parity *************************/

    frame_without_parity_with_stop(8'b10100111);

    #CLK_SIZE
    if (RX_Parallel_Data_tb == 8'b10100111 && RX_Data_Valid_tb == 1)
      $display ("pass1");
    else
      $display ("fail1");

    #(3*CLK_SIZE)
/******************** case2: frame without parity with stop error *************************/

    frame_without_parity_without_stop(8'b01001100);

    RX_Serial_Data_tb = 1;
    #CLK_SIZE    
    RX_Serial_Data_tb = 0;
    #(3*CLK_SIZE)
    RX_Serial_Data_tb = 1;
    #CLK_SIZE
    RX_Serial_Data_tb = 0;
    #(3*CLK_SIZE)
    RX_Serial_Data_tb = 1;


    #CLK_SIZE
    if (RX_Parallel_Data_tb == 8'b01001100 && RX_Data_Valid_tb == 0)
      $display ("pass2");
    else
      $display ("fail2");

    #(3*CLK_SIZE)
/******************** case3: start glitching , no frame *************************/


    RX_Serial_Data_tb = 0;
    #CLK_SIZE    
    RX_Serial_Data_tb = 1;
    #(3*CLK_SIZE)
    RX_Serial_Data_tb = 0;
    #CLK_SIZE
    RX_Serial_Data_tb = 1;
    #(3*CLK_SIZE)

    #(72*CLK_SIZE)

    #CLK_SIZE
    if (RX_Parallel_Data_tb == 8'b01001100 && RX_Data_Valid_tb == 0)
      $display ("pass3");
    else
      $display ("fail3");

    #(3*CLK_SIZE)

/******************** case4: frame with right even parity *************************/

    RX_Parity_Enable_tb = 1;
    RX_Parity_Type_tb = 0;

    frame_with_parity_with_stop(9'b001100110);

    #CLK_SIZE
    if (RX_Parallel_Data_tb == 8'b01100110 && RX_Data_Valid_tb == 1)
      $display ("pass4");
    else
      $display ("fail4");

    #(3*CLK_SIZE)

/******************** case5: frame with wrong even parity *************************/

    frame_with_parity_with_stop(9'b101100110);

    #CLK_SIZE
    if (RX_Parallel_Data_tb == 8'b01100110 && RX_Data_Valid_tb == 0)
      $display ("pass5");
    else
      $display ("fail5");

    #(3*CLK_SIZE)

/******************** case6: frame with right odd parity *************************/

    RX_Parity_Type_tb = 1;

    frame_with_parity_with_stop(9'b111001100);

    #(CLK_SIZE)
    if (RX_Parallel_Data_tb == 8'b11001100 && RX_Data_Valid_tb == 1)
      $display ("pass6");
    else
      $display ("fail6");

    #(3*CLK_SIZE)

/******************** case7: frame with wrong odd parity *************************/

    frame_with_parity_with_stop(9'b101100111);

    #(CLK_SIZE)
    if (RX_Parallel_Data_tb == 8'b01100111 && RX_Data_Valid_tb == 0)
      $display ("pass7");
    else
      $display ("fail7");

    #(3*CLK_SIZE)

/******************** case8: frame with right parity and stop error *************************/

    frame_with_parity_without_stop(9'b001100111);

    RX_Serial_Data_tb = 1;
    #CLK_SIZE    
    RX_Serial_Data_tb = 0;
    #(3*CLK_SIZE)
    RX_Serial_Data_tb = 1;
    #CLK_SIZE
    RX_Serial_Data_tb = 0;
    #(3*CLK_SIZE)
    RX_Serial_Data_tb = 1;


    #(CLK_SIZE)
    if (RX_Parallel_Data_tb == 8'b01100111 && RX_Data_Valid_tb == 0)
      $display ("pass8");
    else
      $display ("fail8");

    #(3*CLK_SIZE)

/******************** case9: rame with wrong parity and stop error *************************/

    frame_with_parity_without_stop(9'b011100001);

    RX_Serial_Data_tb = 1;
    #CLK_SIZE    
    RX_Serial_Data_tb = 0;
    #(3*CLK_SIZE)
    RX_Serial_Data_tb = 1;
    #CLK_SIZE
    RX_Serial_Data_tb = 0;
    #(3*CLK_SIZE)
    RX_Serial_Data_tb = 1;


    #(CLK_SIZE)
    if (RX_Parallel_Data_tb == 8'b11100001 && RX_Data_Valid_tb == 0)
      $display ("pass9");
    else
      $display ("fail9");

    #(3*CLK_SIZE)

/******************** case10: 2 frames *************************/

    frame_with_parity_with_stop(9'b111100001);
    
    frame_with_parity_with_stop(9'b000010000);

    #(2*CLK_SIZE)

    /*look on wave you will found that 
      the 2 frames has been sent correctly 
      and there are valid signal after each frame*/ 

/***********************************************************************************/
  
  
  $stop;

  end
    

always #(CLK_SIZE/2.0) RX_CLK_tb = !RX_CLK_tb;



task frame_with_parity_with_stop 
(
  input [8:0]  rx_in
);
begin
    RX_Serial_Data_tb = 0;
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[0];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[1];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[2];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[3];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[4];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[5];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[6];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[7];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[8];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = 1;
    #(8*CLK_SIZE);
end
endtask


task frame_without_parity_with_stop 
(
  input [7:0]  rx_in
);
begin
    RX_Serial_Data_tb = 0;
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[0];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[1];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[2];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[3];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[4];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[5];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[6];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[7];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = 1;
    #(8*CLK_SIZE);
end
endtask

task frame_with_parity_without_stop 
(
  input [8:0]  rx_in
);
begin
    RX_Serial_Data_tb = 0;
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[0];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[1];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[2];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[3];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[4];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[5];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[6];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[7];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[8];
    #(8*CLK_SIZE);
end
endtask

task frame_without_parity_without_stop 
(
  input [7:0]  rx_in
);
begin
    RX_Serial_Data_tb = 0;
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[0];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[1];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[2];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[3];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[4];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[5];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[6];
    #(8*CLK_SIZE)
    RX_Serial_Data_tb = rx_in[7];
    #(8*CLK_SIZE);
end
endtask


UART_RX_TOP DUT
(
  .RX_CLK           (RX_CLK_tb           ),
  .RX_RST           (RX_RST_tb           ),
  .RX_Serial_Data   (RX_Serial_Data_tb   ),
  .RX_Parity_Enable (RX_Parity_Enable_tb ),
  .RX_Parity_Type   (RX_Parity_Type_tb   ),
  .RX_Prescale      (RX_Prescale_tb      ),
  .RX_Data_Valid    (RX_Data_Valid_tb    ),
  .RX_Parallel_Data (RX_Parallel_Data_tb )
);



endmodule


