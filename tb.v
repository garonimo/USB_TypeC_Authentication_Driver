/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es el test bench
*/


`timescale 10ns/1ps

`include "Parameters.v"

module test;

initial begin
  $dumpfile("USB_Host_model.vcd");
  $dumpvars(0,test);
end


wire reset;
wire resp_req_in,resp_req_out,Ack_out_resp,Ack_in;
wire PD_ready, DEBUG_ready, auth_msg_ready;
wire PD_msg_ready, DEBUG_msg_ready;
wire [`MSG_LEN-1:0] auth_msg_out, auth_msg_in;
wire [7:0] pending_auth_request_PD;
wire [7:0] pending_auth_request_DEBUG;
wire [7:0] bmRequestType;
wire [7:0] bRequest;
wire [15:0] wLength;
wire pending_auth_request_DEBUG_erase, pending_auth_request_PD_erase;


PD_DEBUG_Driver_model In_generator
  (
    .reset(reset),
    .PD_ready(PD_ready),
    .DEBUG_ready(DEBUG_ready),
    .PD_msg_ready(PD_msg_ready),
    .DEBUG_msg_ready(DEBUG_msg_ready),
    .Ack_in_driver(Ack_in),
    .pending_auth_request_PD(pending_auth_request_PD),
    .pending_auth_request_DEBUG(pending_auth_request_DEBUG),
    .pending_auth_request_DEBUG_erase(pending_auth_request_DEBUG_erase),
    .pending_auth_request_PD_erase(pending_auth_request_PD_erase),
    .resp_req_in(resp_req_in),
    .auth_msg_in(auth_msg_in),
    .auth_msg_out(auth_msg_out),
    .auth_msg_ready(auth_msg_ready),
    .clk(clk)
  );

authentication_driver My_authentication_driver
  (
    .clk(clk),
    .reset(reset),
    .auth_msg_in(auth_msg_in),
    .Ack_in(Ack_in),
    .pending_auth_request_PD(pending_auth_request_PD),
    .pending_auth_request_DEBUG(pending_auth_request_DEBUG),
    .pending_auth_request_DEBUG_erase(pending_auth_request_DEBUG_erase),
    .pending_auth_request_PD_erase(pending_auth_request_PD_erase),
    .PD_out_ready(PD_ready),
    .DEBUG_out_ready(DEBUG_ready),
    .PD_msg_ready(PD_msg_ready),
    .DEBUG_msg_ready(DEBUG_msg_ready),
    .auth_msg_ready(auth_msg_ready),
    .auth_msg_out(auth_msg_out)
  );


endmodule
