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

  //Variables del modulo
  integer init_timeout_counter = 0;
  integer current_timeout;
  wire error;
  reg [8:0] ProtocolVersion,MessageType,Param1,Param2;


  //-------------------------Inicio del código---------------------------------

  //Para el manejo de los timeout
  always @(posedge clk) begin
    if (read_req_out | reset) begin
      init_timeout_counter = 0;
    end
    else if (read_req_in) begin
      init_timeout_counter += 1;
    end
  end

endmodule // initiator
