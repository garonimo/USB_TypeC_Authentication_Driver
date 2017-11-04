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
    input wire PD_ready,
    input wire DEBUG_ready,
    input wire auth_msg_ready,
    input wire pending_auth_request_PD_erase,
    input wire pending_auth_request_DEBUG_erase,
    output wire PD_msg_ready,
    output wire DEBUG_msg_ready,
    output wire Ack_in_driver,
    output wire [`MSG_LEN-1:0] auth_msg_in,
    output wire [7:0] pending_auth_request_PD,
    output wire [7:0] pending_auth_request_DEBUG,
    output resp_req_in,
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

  reg [`MSG_LEN-1:0] auth_msg_in_temp = {`HEADER_CERTIFICATE_SLOT0,`SLOT0_CERT1};
  initial begin
    # 600 auth_msg_in_temp = {`HEADER_CERTIFICATE_SLOT0,`SLOT0_CERT2};
    # 600 auth_msg_in_temp = {`HEADER_CERTIFICATE_SLOT0,`SLOT0_CERT3};
    # 600 auth_msg_in_temp = {`HEADER_CERTIFICATE_SLOT0,`SLOT0_CERT4};
    # 600 auth_msg_in_temp = {`HEADER_CERTIFICATE_SLOT0,`SLOT0_CERT5};
    # 600 auth_msg_in_temp = {`HEADER_CERTIFICATE_SLOT0,`SLOT0_CERT6};
    # 100 $finish;
  end
  assign auth_msg_in = auth_msg_in_temp;

  reg [7:0] pending_auth_request_PD_temp = {2'b00,2'b10,2'b00,2'b11};
  assign pending_auth_request_PD = pending_auth_request_PD_temp;

  reg reset = 1;
  initial begin
    # 40 reset = 0;
  end



endmodule //PD_DEBUG_Driver_model
