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
  reg Error_Busy_temp,Error_Unsupported_Protocol_temp,Error_Invalid_Request_temp = 0;
  wire Error_Invalid_Request,Error_Unspecified,Error_Busy,Error_Unsupported_Protocol;
  wire Error_Invalid_Request_challenge;
  reg [`SIZE_OF_HEADER_VARS-1:0] ProtocolVersion_in,MessageType_in,Param1_in,Param2_in;
  wire [`SIZE_OF_HEADER_VARS-1:0] Param1;
  reg [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header;
  wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_challenge,header_digests,header_error;
  reg [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload;
  wire [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_challenge,payload_digests;
  wire payload_error; //must be erased
  wire Error_MSG_ready,error_response_enable;
  reg error_response_enable_temp;
  reg [`SIZE_OF_STATES_RESP-1:0] state, next_state;
  reg [`MSG_LEN-1:0] auth_msg_resp_out_temp;
  reg resp_req_out_temp, Ack_in_get_digests;
  wire Ack_out_get_digests,challenge_enable,challenge_answer_Ack_in;
  reg challenge_enable_temp;

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

  get_digests_answer answer_to_digests
    (
      .clk(clk),
      .Ack_in(Ack_in_get_digests),
      .header(header_digests),
      .Ack_out(Ack_out_get_digests),
      .payload(payload_digests)
    );

  challenge_answer answer_to_challenge
    (
      .clk(clk),
      .Enable(challenge_enable),
      .auth_msg_resp_in(auth_msg_resp_in),
      .Param1(Param1),
      .Error_Invalid_Request(Error_Invalid_Request_challenge),
      .header(header_challenge),
      .Ack_out(challenge_answer_Ack_in),
      .payload(payload_challenge)
    );


  error_response answer_with_error
    (
      .clk(clk),
      .Enable(error_response_enable),
      .Error_Invalid_Request(Error_Invalid_Request),
      .Error_Invalid_Request_challenge(Error_Invalid_Request_challenge),
      .Error_Busy(Error_Busy),
      .Error_Unsupported_Protocol(Error_Unsupported_Protocol),
      .Error_Unspecified(Error_Unspecified),
      .header(header_error),
      .payload(payload_error),
      .MSG_ready(Error_MSG_ready)
    );


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
              Error_Unsupported_Protocol_temp <= 1'b1;
          end else begin
              Error_Unsupported_Protocol_temp <= 1'b0;
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

          default: Error_Invalid_Request_temp = 1'b1;
        endcase
     end // WHICH_REQ

     GET_DIGESTS:
     begin
        if (Ack_out_get_digests == 1'b1) begin
          next_state = SEND_MSG;
        end else begin
          next_state = GET_DIGESTS;
        end
     end //GET_DIGESTS

     GET_CERTIFICATE:
     begin
        next_state = SEND_MSG;
     end

     CHALLENGE:
     begin
        if (challenge_answer_Ack_in == 1'b1) begin
          next_state = SEND_MSG;
        end else begin
          next_state = CHALLENGE;
        end
     end //CHALLENGE

     GEN_ERROR:
     begin
      if (Error_MSG_ready) begin
        next_state = SEND_MSG;
      end else begin
        next_state = GEN_ERROR;
      end
     end

     SEND_MSG:
     begin
       if (Ack_in) begin
          next_state = IDLE;
       end
       else begin
          next_state = SEND_MSG;
       end
     end

     default: next_state = IDLE;
    endcase

  end //Always-RESPONDER_COMB

//-------------------------Lógica secuencial------------------------------------

 always @ (posedge clk) begin : Resp_SEQ
   if (reset == 1'b1) begin
     state <= IDLE;
   end
   else if ((Error_Busy_temp | Error_Unsupported_Protocol_temp | Error_Invalid_Request | Error_Unspecified) && (state != GEN_ERROR)) begin
     state <= GEN_ERROR;
   end
   else begin
     state <= next_state;
   end
 end // Always-Resp_SEQ

 //---------------------------Lógica de salida----------------------------------
   always @ (negedge clk) begin : Resp_OUTPUT
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

         GET_DIGESTS: begin
            payload <= payload_digests;
            header <= header_digests;
            Ack_in_get_digests <= 1'b1;
         end

         CHALLENGE:
         begin
            header <= header_challenge;
            payload <= payload_challenge;
            challenge_enable_temp = 1'b1;
         end

         GEN_ERROR:
         begin
            header <= header_error;
            payload <= payload_error;
            error_response_enable_temp <= 1'b1;
         end

         SEND_MSG:
         begin
           error_response_enable_temp <= 1'b0;
           Error_Busy_temp <= 1'b0;
           Error_Unsupported_Protocol_temp <= 1'b0;
           Error_Invalid_Request_temp <= 1'b0;
           challenge_enable_temp <= 1'b0;
           Ack_in_get_digests <= 1'b0;
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
 assign Error_Busy = Error_Busy_temp;
 assign Error_Unsupported_Protocol = Error_Unsupported_Protocol_temp;
 assign Error_Invalid_Request = Error_Invalid_Request_temp;
 assign Param1 = Param1_in;
 assign challenge_enable = challenge_enable_temp;
 assign error_response_enable  = error_response_enable_temp;


endmodule // responder
