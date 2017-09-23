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
wire resp_req_in,resp_req_out,Ack_out_resp;
wire [`MSG_LEN-1:0] auth_msg_resp_out, auth_msg_resp_in;


USB_Host_model HOST
  (
    .CC1(CC1),
    .CC2(CC2),
    .TX2_m(TX2_m),
    .TX2_p(TX2_p),
    .reset(reset),
    .resp_req_in(resp_req_in),
    .auth_msg_resp_in(auth_msg_resp_in),
    .auth_msg_resp_out(auth_msg_resp_out),
    .Ack_out_resp(Ack_out_resp),
    .clk(clk)
  );

  driver_authentication_test FSM_TEST
    (
      .CC1(CC1),
      .CC2(CC2),
      .TX2_m(TX2_m),
      .TX2_p(TX2_p),
      .reset(reset),
      .clk(clk)
    );

  responder resp_test
    (
      .clk(clk),
      .reset(reset),
      .resp_req_in(resp_req_in),
      .auth_msg_resp_in(auth_msg_resp_in),
      .Ack_in(Ack_out_resp),
      .resp_req_out(resp_req_out),
      .auth_msg_resp_out(auth_msg_resp_out)
    );

endmodule
