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

module test;

initial begin
  $dumpfile("USB_Host_model.vcd");
  $dumpvars(0,test);
end

//Pins del receptáculo del type-C
wire TX1_p,TX1_m,VBUS,CC1,D1_p,D1_m,SBU1,RX2_m,RX2_p;
wire RX1_p,RX1_m,SBU2,D2_m,D2_p,CC2,TX2_m,TX2_p,clk,reset;


USB_Host_model HOST
  (
    .TX1_p(TX1_p),
    .TX1_m(TX1_m),
    .VBUS(VBUS),
    .CC1(CC1),
    .D1_p(D1_p),
    .D1_m(D1_m),
    .SBU1(SBU1),
    .RX2_m(RX2_m),
    .RX2_p(RX2_p),
    .RX1_p(RX1_p),
    .RX1_m(RX1_m),
    .SBU2(SBU2),
    .CC2(CC2),
    .TX2_m(TX2_m),
    .TX2_p(TX2_p),
    .reset(reset),
    .clk(clk)
  );

  driver_authentication_test FSM_TEST
    (
      .TX1_p(TX1_p),
      .TX1_m(TX1_m),
      .VBUS(VBUS),
      .CC1(CC1),
      .D1_p(D1_p),
      .D1_m(D1_m),
      .SBU1(SBU1),
      .RX2_m(RX2_m),
      .RX2_p(RX2_p),
      .RX1_p(RX1_p),
      .RX1_m(RX1_m),
      .SBU2(SBU2),
      .CC2(CC2),
      .TX2_m(TX2_m),
      .TX2_p(TX2_p),
      .reset(reset),
      .clk(clk)
    );

endmodule
