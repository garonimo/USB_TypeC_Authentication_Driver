/*
*	Universidad de Costa Rica
*	Escuela de Ingeniería Eléctrica
* Proyecto Eléctrico
*
*	Autor: Andrés Sánchez López - B26214
*
*	Descripción: Este archivo es el authentication responder
*/

`include "Parameters.v"

module responder
  (
    input wire clk,
    input wire reset,
    input wire resp_req_in,
    input wire [`MSG_LEN-1:0] auth_msg_resp_in,
    input wire Ack_in,
    output wire resp_req_out,
    output wire [`MSG_LEN-1:0] auth_msg_resp_out
  );

  //states
  parameter IDLE = 8'b00000001, GET_DATA = 8'b00000010, GEN_ERROR = 8'b00000100;
  parameter WHICH_REQ = 8'b00001000, GET_CERTIFICATE = 8'b00010000;
  parameter CHALLENGE = 8'b00100000, GET_DIGESTS = 8'b01000000;
  parameter SEND_MSG = 8'b10000000;
  //variables
  integer current_timeout;
  reg Error_Busy,Error_Unsupported_Protocol,Error_Invalid_Request,Error_Unspecified = 0;
  reg [`SIZE_OF_HEADER_VARS-1:0] ProtocolVersion_in,MessageType_in,Param1_in,Param2_in;
  wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header = {ProtocolVersion_in,MessageType_in,Param1_in,Param2_in};
  wire [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload;
  reg [`SIZE_OF_STATES_RESP-1:0] state, next_state;
  reg [`MSG_LEN-1:0] auth_msg_resp_out_temp;
  reg resp_req_out_temp;

  integer resp_timeout_counter = 0;


  //-------------------------Inicio del código---------------------------------

  //Para el manejo de los timeout
  always @(posedge clk) begin
    if (resp_req_out | reset) begin
      resp_timeout_counter = 0;
    end
    else if (resp_req_in) begin
      resp_timeout_counter += 1;
    end
  end

 //----------------------Lógica combinacional ---------------------------------
 always @ (*)
  begin : RESPONDER_COMB
   next_state = 7'b0;
   case (state)
     IDLE: begin
           if (resp_req_in == 1'b1) begin
             next_state = GET_DATA;
           end
           else begin
             next_state = IDLE;
           end
     end //IDLE

     GET_DATA:
     begin
          ProtocolVersion_in = auth_msg_resp_in[`MSG_LEN-1:`MSG_LEN-1-(`SIZE_OF_HEADER_VARS)];
          if (ProtocolVersion_in != 1) begin
              Error_Unsupported_Protocol <= 1'b1;
          end else begin
              Error_Unsupported_Protocol <= 1'b0;
          end
          MessageType_in = auth_msg_resp_in[`MSG_LEN-1-(`SIZE_OF_HEADER_VARS)-1:`MSG_LEN-1-(2*`SIZE_OF_HEADER_VARS)];
          Param1_in = auth_msg_resp_in[`MSG_LEN-1-(2*`SIZE_OF_HEADER_VARS)-1:`MSG_LEN-1-(3*`SIZE_OF_HEADER_VARS)];
          Param2_in = auth_msg_resp_in[`MSG_LEN-1-(3*`SIZE_OF_HEADER_VARS)-1:`MSG_LEN-1-(4*`SIZE_OF_HEADER_VARS)];
          next_state = WHICH_REQ;
     end // GET_DATA

     WHICH_REQ:
     begin
        case(MessageType_in)
          129: next_state = GET_DIGESTS;
          130: next_state = GET_CERTIFICATE;
          131: next_state = CHALLENGE;

          default: Error_Invalid_Request = 1'b1;
        endcase
     end // WHICH_REQ

     GET_DIGESTS: begin
        next_state = SEND_MSG;
     end

     GET_CERTIFICATE: begin
        next_state = SEND_MSG;
     end

     CHALLENGE: begin
        next_state = SEND_MSG;
     end

     GEN_ERROR: begin
        next_state = SEND_MSG;
     end

     SEND_MSG: begin
        next_state = IDLE;
     end

     default: next_state = IDLE;
    endcase

  end //Always-RESPONDER_COMB

//-------------------------Lógica secuencial------------------------------------

 always @ (posedge clk) begin : Resp_SEQ
   if (reset == 1'b1) begin
     state <= IDLE;
   end
   else if (Error_Busy | Error_Unsupported_Protocol | Error_Invalid_Request | Error_Unspecified) begin
     state <= GEN_ERROR;
   end
   else begin
     state <= next_state;
   end
 end // Always-Resp_SEQ

 //---------------------------Lógica de salida----------------------------------
   always @ (posedge clk) begin : Resp_OUTPUT
     if (reset == 1'b1) begin
       resp_req_out_temp <= 1'b0;
       auth_msg_resp_out_temp <= 0;
     end
     else begin
       case (state)

         IDLE: begin
           resp_req_out_temp <= 1'b0;
           auth_msg_resp_out_temp <= 0;
         end

         SEND_MSG: begin
           auth_msg_resp_out_temp <= {header,payload};
           resp_req_out_temp <= 1'b1;
         end

         default: begin
           resp_req_out_temp <= 1'b0;
           auth_msg_resp_out_temp <= 0;
         end

       endcase
     end
   end //Always-Resp_OUTPUT

//-------------------------------End of always code-----------------------------

 assign auth_msg_resp_out = auth_msg_resp_out_temp;
 assign resp_req_out = resp_req_out_temp;

endmodule // responder
