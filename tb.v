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

//Pins del receptáculo del type-C
wire TX1_p,TX1_m,VBUS,CC1,D1_p,D1_m,SBU1,RX2_m,RX2_p;
wire RX1_p,RX1_m,SBU2,D2_m,D2_p,CC2,TX2_m,TX2_p,clk,reset;
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
    .CC1(CC1),
    .CC2(CC2),
    .TX2_m(TX2_m),
    .TX2_p(TX2_p),
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
