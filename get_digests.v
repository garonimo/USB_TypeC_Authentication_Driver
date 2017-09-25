/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es para crear el mensaje de respuesta a un GET_DIGESTS
*/

module get_digests_answer
  (
    input wire clk,
    input wire Ack_in,
    output wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header,
    output wire Ack_out,
    output wire [`MSG_LEN-1-(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES):0] payload
  );

  reg [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_temp;
  reg [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_temp;
  reg Ack_out_temp;
  reg Param1_digests = 1'b1;

  always @ (posedge clk) begin
    if (Ack_in) begin
      header_temp = {`PROTOCOL_VERSION,`DIGESTS_ANSWER_CMD,Param1_digests,`CERT_CHAINS_MASK};
      payload_temp = {32'h4568787,32'hAC786425,32'hF986550};
      Ack_out_temp = 1;
    end else begin
      header_temp = 0;
      payload_temp = 0;
      Ack_out_temp = 0;
    end
  end //Always

  assign header = header_temp;
  assign payload = payload_temp;
  assign Ack_out = Ack_out_temp;

endmodule // get_digests_answer
