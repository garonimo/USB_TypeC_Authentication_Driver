/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es para crear el mensaje de respuesta a un CHALLENGE
*/


module challenge_answer
  (
    input wire clk,
    input wire Enable,
    input wire [`MSG_LEN-1:0] auth_msg_resp_in,
    input wire [`SIZE_OF_HEADER_VARS-1:0] Param1, //Slot a enviar
    output wire Error_Invalid_Request,
    output wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header,
    output wire Ack_out,
    output wire [`MSG_LEN-1-(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES):0] payload
  );

  reg [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_temp;
  reg [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_temp;
  reg Ack_out_temp,Error_Invalid_Request_temp;
  reg [231:0] Payload_in;


  always @ (posedge clk) begin
    if (Enable) begin
      Payload_in = auth_msg_resp_in[255:24];
      if (Payload_in > 0) begin
        header_temp = {`PROTOCOL_VERSION,`CHALLENGE_AUTH_CMD,Param1,`CERT_CHAINS_MASK};
        payload_temp = {`PROTOCOL_VERSION,`PROTOCOL_VERSION,`CAPABILITIES,8'h00,`CHALLENGE_AUTH_HASH};
        Ack_out_temp = 1'b1;
      end else begin
        Error_Invalid_Request_temp = 1'b1;
      end
    end //If Enable
    else begin
      header_temp = 0;
      payload_temp = 0;
      Ack_out_temp = 1'b0;
    end
  end //Always


  assign header = header_temp;
  assign payload = payload_temp;
  assign Ack_out = Ack_out_temp;
  assign Error_Invalid_Request = Error_Invalid_Request_temp;

endmodule //challenge_answer
