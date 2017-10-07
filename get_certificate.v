/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es para crear los mensajes de solicitud de certificados,
* y también para crear la respuesta a estos
*/


module get_certificate_answer
  (
    input wire clk,
    input wire Enable,
    input wire [`MSG_LEN-1:0] auth_msg_resp_in,
    output wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header,
    output wire Ack_out,
    output wire [`MSG_LEN-1-(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES):0] payload
  );

  reg Ack_out_temp;
  reg [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_temp;
  reg [`MSG_LEN-1-(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES):0] payload_temp;


endmodule // get_certificate_answer
