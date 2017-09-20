/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es el authentication initiator
*/


module initiator
  (
    input wire clk,
    input wire reset,
    input wire read_req_in,
    input wire [999:0] auth_msg_init_in,
    output wire read_req_out,
    output wire [999:0] auth_msg_init_out
  );

  int resp_timeout_counter = 0;

endmodule // initiator
