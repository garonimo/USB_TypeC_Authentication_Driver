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
    input wire [`MSG_LEN-1:0] auth_msg_resp_in,
    input wire Ack_in,
    input wire [1:0] slot,
    output wire resp_req_out,
    output wire [7:0] bmRequestType,
    output wire [7:0] bRequest,
    output wire [15:0] wLength,
    output wire [31:0] current_timeout,
    output wire [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload,
    output wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header
  );

  //-------------------------------Parámetros-----------------------------------
  //estados
  parameter IDLE = 9'b000000001, GET_DATA = 9'b000000010, GEN_ERROR = 9'b000000100;
  parameter WHICH_REQ = 9'b000001000, GET_CERTIFICATE = 9'b000010000;
  parameter CHALLENGE = 9'b000100000, GET_DIGESTS = 9'b001000000;
  parameter SEND_MSG = 9'b010000000, ACK = 9'b100000000;

  //--------------------------------Variables-----------------------------------
  //Variables inicializadas
  reg Error_Busy_temp = 0;
  reg Error_Unsupported_Protocol_temp = 0;
  reg Error_Invalid_Request_temp = 0;
  reg Error_Unspecified_temp = 0;
  integer resp_timeout_counter = 0;
  //Variables de error
  wire Error_Invalid_Request,Error_Unspecified,Error_Busy,Error_Unsupported_Protocol;
  wire Error_Invalid_Request_challenge,Error_Invalid_Request_GetCertificate;
  reg [31:0] current_timeout_temp = `CHALLENGE_TIMEOUT_AUTH;
  //Variables del mensaje de autenticacion
  reg [`SIZE_OF_HEADER_VARS-1:0] ProtocolVersion_in,MessageType_in,Param1_in,Param2_in;
  wire [`SIZE_OF_HEADER_VARS-1:0] Param1;
  reg [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_temp;
  wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_challenge,header_digests,header_error;
  wire [(`SIZE_OF_HEADER_VARS*`SIZE_OF_HEADER_IN_BYTES)-1:0] header_GetCertificate;
  reg [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_temp;
  wire [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_challenge,payload_digests;
  wire [`MSG_LEN-1-((`SIZE_OF_HEADER_VARS)*`SIZE_OF_HEADER_IN_BYTES):0] payload_GetCertificate;
  wire payload_error; //must be erased
  //Variables para mensajes sobre USB
  reg [7:0] bmRequestType_temp;
  reg [7:0] bRequest_temp;
  reg [15:0] wLength_temp;
  wire [15:0] wLength_GetCertificate;
  //Variables para "handshakes"
  wire Error_MSG_ready,error_response_enable,get_certificate_enable;
  reg error_response_enable_temp,get_certificate_enable_temp;
  reg [`MSG_LEN-1:0] auth_msg_resp_out_temp;
  reg resp_req_out_temp, Ack_in_get_digests;
  wire GetCertificate_answer_Ack_in;
  wire Ack_out_get_digests,challenge_enable,challenge_answer_Ack_in;
  reg challenge_enable_temp;
  //Variables de estado
  reg [`SIZE_OF_STATES_RESP-1:0] state, next_state;


  //////////////////////////////////////////////////////////////////////////////
  //-------------------------Inicio del código----------------------------------
  //////////////////////////////////////////////////////////////////////////////


//---------------------------Instancias-----------------------------------------

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

  get_certificate_answer answer_to_GetCertificate
    (
      .clk(clk),
      .Enable(get_certificate_enable),
      .auth_msg_resp_in(auth_msg_resp_in),
      .Param1(Param1),
      .Error_Invalid_Request(Error_Invalid_Request_GetCertificate),
      .header(header_GetCertificate),
      .Ack_out(GetCertificate_answer_Ack_in),
      .wLength(wLength_GetCertificate),
      .payload(payload_GetCertificate)
    );

  error_response answer_with_error
    (
      .clk(clk),
      .Enable(error_response_enable),
      .Error_Invalid_Request(Error_Invalid_Request),
      .Error_Invalid_Request_challenge(Error_Invalid_Request_challenge),
      .Error_Invalid_Request_GetCertificate(Error_Invalid_Request_GetCertificate),
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
   next_state = 9'b0;
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
          ProtocolVersion_in = auth_msg_resp_in[`MSG_LEN-1:`MSG_LEN-(`SIZE_OF_HEADER_VARS)];
          if (ProtocolVersion_in != 1) begin
              Error_Unsupported_Protocol_temp <= 1'b1;
          end else begin
              Error_Unsupported_Protocol_temp <= 1'b0;
          end
          MessageType_in = auth_msg_resp_in[`MSG_LEN-1-(`SIZE_OF_HEADER_VARS):`MSG_LEN-(2*`SIZE_OF_HEADER_VARS)];
          Param1_in = auth_msg_resp_in[`MSG_LEN-1-(2*`SIZE_OF_HEADER_VARS):`MSG_LEN-(3*`SIZE_OF_HEADER_VARS)];
          Param2_in = auth_msg_resp_in[`MSG_LEN-1-(3*`SIZE_OF_HEADER_VARS):`MSG_LEN-(4*`SIZE_OF_HEADER_VARS)];
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
         if (GetCertificate_answer_Ack_in == 1'b1) begin
           next_state = SEND_MSG;
         end else begin
           next_state = GET_CERTIFICATE;
         end
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
       if (header) begin
          next_state = ACK;
       end
       else begin
          next_state = SEND_MSG;
       end
     end

     ACK:
     begin
       if (Ack_in) begin
          next_state = IDLE;
       end
       else begin
          next_state = ACK;
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
       header_temp <= 0;
       payload_temp <= 0;
     end
     else begin
       case (state)

         IDLE:
         begin
           resp_timeout_counter <= 0;
           resp_req_out_temp <= 1'b0;
           header_temp <= 0;
           payload_temp <= 0;
         end

         GET_DIGESTS: begin
            bmRequestType_temp <= 128;
            bRequest_temp <= 24;
            wLength_temp <= 260;
            current_timeout_temp <= `DIGEST_ANW_TIMEOUT;
            payload_temp <= payload_digests;
            header_temp <= header_digests;
            Ack_in_get_digests <= 1'b1;
         end

         CHALLENGE:
         begin
            bmRequestType_temp <= 0;
            bRequest_temp <= 25;
            wLength_temp <= 32;
            current_timeout_temp <= `CHALLENGE_TIMEOUT_AUTH;
            header_temp <= header_challenge;
            payload_temp <= payload_challenge;
            challenge_enable_temp = 1'b1;
         end

         GET_CERTIFICATE:
         begin
            bmRequestType_temp <= 0;
            bRequest_temp <= 25;
            wLength_temp <= wLength_GetCertificate;
            current_timeout_temp <= `CERTIFICATE_ANW_TIMEOUT;
            header_temp <= header_GetCertificate;
            payload_temp <= payload_GetCertificate;
            get_certificate_enable_temp = 1'b1;
         end

         GEN_ERROR:
         begin
            header_temp <= header_error;
            payload_temp <= payload_error;
            error_response_enable_temp <= 1'b1;
         end

         SEND_MSG:
         begin
          //Primero se borran algunas variables que pudieron quedar en uno
           error_response_enable_temp <= 1'b0;
           Error_Busy_temp <= 1'b0;
           Error_Unsupported_Protocol_temp <= 1'b0;
           Error_Invalid_Request_temp <= 1'b0;
           challenge_enable_temp <= 1'b0;
           get_certificate_enable_temp = 1'b0;
           Ack_in_get_digests <= 1'b0;
         end

         ACK:
         begin
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

 assign resp_req_out = resp_req_out_temp;
 assign Error_Busy = Error_Busy_temp;
 assign Error_Unsupported_Protocol = Error_Unsupported_Protocol_temp;
 assign Error_Invalid_Request = Error_Invalid_Request_temp;
 assign Error_Unspecified = Error_Unspecified_temp;
 assign Param1 = Param1_in;
 assign challenge_enable = challenge_enable_temp;
 assign error_response_enable  = error_response_enable_temp;
 assign get_certificate_enable = get_certificate_enable_temp;
 assign header = header_temp;
 assign payload = payload_temp;
 assign bmRequestType = bmRequestType_temp;
 assign bRequest = bRequest_temp;
 assign wLength = wLength_temp;
 assign current_timeout = current_timeout_temp;

endmodule // responder
