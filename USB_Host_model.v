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
    input wire resp_req_out,
    input wire [`MSG_LEN-1:0] auth_msg_resp_out,
    output wire [`MSG_LEN-1:0] auth_msg_resp_in,
    output Ack_out_resp,
    output resp_req_in,
    output CC1,
    output CC2,
    input wire TX2_m,
    input wire TX2_p,
    output reset,
    output clk
  );

  reg clk = 0;
  always #10 clk = !clk;         //100 MHz

  reg resp_req_in = 1;
  always @(posedge clk) begin
    if (resp_req_out) begin
      resp_req_in = 0;
    end
  end //Always

  reg Ack_out_resp = 1;

  reg [`MSG_LEN-1:0] auth_msg_resp_in_temp = {8'b00000001,8'b10000001,2063'b100000001000001};
  assign auth_msg_resp_in = auth_msg_resp_in_temp;

  reg reset = 1;
  initial begin
    # 40 reset = 0;
  end

  reg CC1 = 0;
  initial begin
    # 95  CC1 = 1;
    # 200  CC1 = 0;
    # 200 $finish;
  end

  reg CC2 = 1;
  initial begin
    # 100  CC2 = 0;
    # 200  CC2 = 1;
    # 200 $finish;
  end


endmodule
