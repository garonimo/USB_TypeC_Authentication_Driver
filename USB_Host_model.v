/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es el modelo del USB host, genera las señales
* que van hacia el controlador y responde a los mensajes de este
*/


`timescale 10ns/1ps

module USB_Host_model
  (
    input wire TX1_p,
    input wire TX1_m,
    output reg VBUS,
    output CC1,
    output D1_p,   /*no se si entrada o salida*/
    output D1_m,   /*no se si entrada o salida*/
    output SBU1,
    output RX2_m,
    output RX2_p,
    output RX1_p,
    output RX1_m,
    output SBU2,
    output CC2,
    input wire TX2_m,
    input wire TX2_p,
    output reset,
    output clk
  );

  reg clk = 0;
  always #10 clk = !clk;         //100 MHz

  reg reset = 1;
  initial begin
    # 2 reset = 0;
  end

  reg CC1 = 0;
  initial begin
    # 95  CC1 = 1;
    # 200  CC1 = 0;
    # 50 $finish;
  end

  reg CC2 = 1;
  initial begin
    # 100  CC2 = 0;
    # 200  CC2 = 1;
    # 50 $finish;
  end


endmodule
