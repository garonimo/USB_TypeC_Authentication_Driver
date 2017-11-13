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

  reg [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_temp = 0;
  reg [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_temp = 0;
  reg Ack_out_temp = 0;
  reg [7:0] Param1_digests = 8'h01;

  always @ (posedge clk) begin
    Param1_digests = 8'h01;
    if (Ack_in == 1'b1) begin
      header_temp = {`PROTOCOL_VERSION,`DIGESTS_ANSWER_CMD,Param1_digests,`CERT_CHAINS_MASK};
      payload_temp = {2048'h3579683435680133346733346733713467337274673367657267646651651651651651};
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
