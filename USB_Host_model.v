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

module PD_DEBUG_Driver_model
  (
    input wire resp_req_out,
    input wire [`MSG_LEN-1:0] auth_msg_out,
    input wire PD_in_ready,
    input wire DEBUG_in_ready,
    input wire auth_msg_ready,
    input wire pending_auth_request_PD_erase,
    input wire pending_auth_request_DEBUG_erase,
    output wire Ack_in_driver,
    output wire [`MSG_LEN-1:0] auth_msg_in,
    output wire [7:0] pending_auth_request_PD,
    output wire [7:0] pending_auth_request_DEBUG,
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

  reg Ack_in_driver_temp;

  reg resp_req_in = 1;
  always @(posedge clk) begin

    if (resp_req_out) begin
      resp_req_in = 0;
    end

    if (auth_msg_ready) begin
      Ack_in_driver_temp <= 1;
    end else begin
      Ack_in_driver_temp <= 0;
    end

  end //Always


  assign Ack_in_driver = Ack_in_driver_temp;

  reg [`MSG_LEN-1:0] auth_msg_in_temp = {8'h01,8'h82,8'h00,8'h00,16'h0000,16'h0103,2016'h10365616516471691681};
  initial begin
    # 300 auth_msg_in_temp = {8'h01,8'h82,8'h00,8'h00,16'b00,16'h0095,2016'h10365616516471691681};
  end
  assign auth_msg_in = auth_msg_in_temp;

  reg [7:0] pending_auth_request_PD_temp = {2'b00,2'b10,2'b00,2'b11};
  assign pending_auth_request_PD = pending_auth_request_PD_temp;

  reg reset = 1;
  initial begin
    # 40 reset = 0;
  end

  reg CC1 = 0;
  initial begin
    # 95  CC1 = 1;
    # 200  CC1 = 0;
    # 350 $finish;
  end

  reg CC2 = 1;
  initial begin
    # 100  CC2 = 0;
    # 200  CC2 = 1;
    # 350 $finish;
  end


endmodule //PD_DEBUG_Driver_model
