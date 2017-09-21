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
    input wire init_req_in,
    input wire [999:0] auth_msg_init_in,
    output wire init_req_out,
    output wire [999:0] auth_msg_init_out
  );

  //constantes
  parameter size_of_states_init = 7;
  parameter GET_CERTIFICATE_timeout = 200, CHALLENGE_timeout = 1200, GET_DIGESTS_timeout = 200; //ms
  //states
  parameter IDLE = 7'b0000001, GEN_ERROR = 7'b0000100;
  parameter WHICH_REQ = 7'b0001000, GET_CERTIFICATE = 7'b0010000;
  parameter CHALLENGE = 7'b0100000, GET_DIGESTS = 7'b1000000;
  //Variables del módulo
  integer init_timeout_counter = 0;
  integer current_timeout;
  wire Error_Busy,Error_Invalid_Response,Error_Unspecified;
  reg [size_of_states_init-1:0] state, next_state;

  //-------------------------Inicio del código---------------------------------

  //Para el manejo de los timeout
  always @(posedge clk) begin
    if (init_req_out | reset) begin
      init_timeout_counter = 0;
    end
    else if (init_req_in) begin
      init_timeout_counter += 1;
    end
  end

endmodule // initiator
