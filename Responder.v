/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es el authentication responder
*/


module responder
  (
    input wire clk,
    input wire reset,
    input wire resp_req_in,
    input wire [999:0] auth_msg_resp_in,
    output wire resp_req_out,
    output wire [999:0] auth_msg_resp_out
  );

  int resp_timeout_counter = 0;

endmodule // responder
